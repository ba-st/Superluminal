Class {
	#name : 'RESTfulAPIClient',
	#superclass : 'Object',
	#instVars : [
		'httpClientProvider',
		'httpClientPoolByAuthority',
		'entityTagByLocationCache',
		'lastKnownRepresentationByLocation',
		'expiringCache',
		'errorHandlers'
	],
	#category : 'Superluminal-RESTfulAPI',
	#package : 'Superluminal-RESTfulAPI'
}

{ #category : 'instance creation' }
RESTfulAPIClient class >> buildingHttpClientWith: anHttpClientProvider cachingIn: anExpiringCache [

	^ self new initializeBuildingHttpClientWith: anHttpClientProvider cachingIn: anExpiringCache
]

{ #category : 'instance creation' }
RESTfulAPIClient class >> cachingOnLocalMemory [

	^ self buildingHttpClientWith: [ ZnClient new ] cachingIn: ExpiringCache onLocalMemory
]

{ #category : 'private - caching' }
RESTfulAPIClient >> addSetIfNoneMatchHeaderTo: command configuredUsing: request ifCached: aLocation [

	self
		withCachedETagAt: aLocation
		do: [:entityTag | ^command + (request headers setIfNoneMatchTo: entityTag)].
	^command
]

{ #category : 'private - inkoving' }
RESTfulAPIClient >> clientPoolFor: aLocation [

	^ httpClientPoolByAuthority
		at: aLocation asAbsoluteUrl authorityWithPort
		ifAbsentPut: [ OPBasicPool new
				creator: httpClientProvider;
				destroyer: #close;
				passivator: #resetRequest;
				maxActiveObjects: 5;
				minIdleObjects: 1;
				yourself 
			]
]

{ #category : 'private - exception handling' }
RESTfulAPIClient >> defaultErrorHandlers [

  ^ Array with: ZnMimeType applicationJson -> [ :error :response |
        ( ( NeoJSONObject fromString: response contents ) at: #message ) ifNotNil: [ :message |
            error messageText: message ]
      ]
]

{ #category : 'invoking - covenience' }
RESTfulAPIClient >> deleteAt: aLocation [

	^ self
		deleteAt: aLocation
		configuredBy: [ :request | 
			self
				withETagAt: aLocation
				do: [ :entityTag | request headers setIfMatchTo: entityTag asString ]
			]
		withSuccessfulResponseDo: [  ]
]

{ #category : 'invoking - covenience' }
RESTfulAPIClient >> deleteAt: aLocation accepting: aMediaType withSuccessfulResponseDo: aBlock [

	^ self
		deleteAt: aLocation
		configuredBy: [ :request | 
			| command |

			command := request headers setAcceptTo: aMediaType.
			self
				withETagAt: aLocation
				do: [ :entityTag | command := command + ( request headers setIfMatchTo: entityTag asString ) ].
			command
			]
		withSuccessfulResponseDo: aBlock
]

{ #category : 'invoking' }
RESTfulAPIClient >> deleteAt: aLocation configuredBy: aRequestBuildingBlock withSuccessfulResponseDo: aBlock [

  ^ self handleExceptionsDuring: [
        | httpRequest response |
        httpRequest := HttpRequest delete: aLocation configuredUsing: aRequestBuildingBlock.
        self
          withHttpClientFor: aLocation
          do: [ :httpClient | response := httpRequest applyOn: httpClient ].
        ( response isSuccess or: [ response isNoContent ] )
          ifTrue: [
              expiringCache clearResourceAt: aLocation.
              aBlock cull: ( self tryToCacheContentsOf: response basedOn: aLocation )
            ]
          ifFalse: [
              self
                signalErrorBasedOn: response
                answeredFor: aLocation
                describedByDefaultAs: 'Cannot complete delete'
            ]
      ]
]

{ #category : 'private - exception handling' }
RESTfulAPIClient >> errorBasedOn: aResponse answeredFor: aLocation describedByDefaultAs: aDefaultMessage [
  "A block that fails to describe the error doesn't change the outcome: the error is still signaled, with its default message"

  | error |
  error := self undescribedErrorBasedOn: aResponse withMessage: aDefaultMessage.
  self withErrorHandlerFor: aResponse do: [ :handler |
      [ handler value: error value: aResponse ]
        on: Error
        do: [ :failure |
            LogRecord emitWarning:
              ( 'Ignoring the description of the <1p> error answered for <2s>: <3s>'
                  expandMacrosWith: aResponse code
                  with: aLocation asString
                  with: failure messageText ).
            ^ self undescribedErrorBasedOn: aResponse withMessage: aDefaultMessage
          ]
    ].
  ^ error
]

{ #category : 'private - inkoving' }
RESTfulAPIClient >> execute: httpRequest aimedAt: aLocation [

  ^ self handleExceptionsDuring: [
        | response contents |
        self
          withHttpClientFor: aLocation
          do: [ :httpClient | response := httpRequest applyOn: httpClient ].
        contents := response isNotModified
                      ifTrue: [ self lastKnownRepresentationOf: aLocation ]
                      ifFalse: [
                          response isSuccess
                            ifTrue: [ self tryToCacheContentsOf: response basedOn: aLocation ]
                            ifFalse: [
                                self
                                  signalErrorBasedOn: response
                                  answeredFor: aLocation
                                  describedByDefaultAs: 'Cannot complete the request'
                              ]
                        ].
        ExpiringResource for: contents controlledBy: response
      ]
]

{ #category : 'finalization' }
RESTfulAPIClient >> finalize [

	httpClientPoolByAuthority valuesDo: [ :pool |
		pool
			minIdleObjects: nil;
			clear
		]
]

{ #category : 'invoking - covenience' }
RESTfulAPIClient >> get: aLocation accepting: aMediaType withSuccessfulResponseDo: aBlock [

	^ self
		getAt: aLocation
		configuredBy: [ :request | request headers setAcceptTo: aMediaType ]
		withSuccessfulResponseDo: aBlock
]

{ #category : 'invoking - covenience' }
RESTfulAPIClient >> get: aLocation withSuccessfulResponseDo: aMonadicBlock [

	^ self getAt: aLocation configuredBy: [  ] withSuccessfulResponseDo: aMonadicBlock
]

{ #category : 'invoking' }
RESTfulAPIClient >> getAt: aLocation configuredBy: aRequestBuildingBlock withSuccessfulResponseDo: aMonadicBlock [

  | key request |
  request := self requestToGet: aLocation configuredUsing: aRequestBuildingBlock.
  key := ExpiringCacheKeyBuilder keyFor: request at: aLocation.
  ^ expiringCache
      withResourceAt: key
      obtainedUsing: [ self execute: request aimedAt: aLocation ]
      do: aMonadicBlock
]

{ #category : 'private - exception handling' }
RESTfulAPIClient >> handleExceptionsDuring: anInvokingBlock [

  ^ [
      [
        anInvokingBlock
          on: ConnectionTimedOut
          do: [ :signal | HTTPServerError signalGatewayTimeout: signal messageText ]
      ] on: NetworkError except: ConnectionTimedOut do: [ :signal |
          HTTPServerError signalInternalServerError:
            'Cannot complete the request due to some network error' ]
    ]
      on: AssertionFailed , InstanceCreationFailed , NeoJSONMappingNotFound , NeoJSONParseError
      do: [ :signal | HTTPClientError badRequest signal: signal messageText ]
]

{ #category : 'initialization' }
RESTfulAPIClient >> initializeBuildingHttpClientWith: anHttpClientProvider cachingIn: anExpiringCache [

  httpClientProvider := anHttpClientProvider.
  httpClientPoolByAuthority := Dictionary new.
  entityTagByLocationCache := Dictionary new.
  lastKnownRepresentationByLocation := Dictionary new.
  expiringCache := anExpiringCache.
  errorHandlers := OrderedCollection new
]

{ #category : 'private - caching' }
RESTfulAPIClient >> lastKnownRepresentationOf: aLocation [

	^ lastKnownRepresentationByLocation at: ( self normalize: aLocation )
]

{ #category : 'private - caching' }
RESTfulAPIClient >> normalize: aLocation [

	^aLocation asString
]

{ #category : 'configuring' }
RESTfulAPIClient >> onErrorsTyped: aMediaType do: aBlock [
  "When an error response is typed as aMediaType, which may be a pattern like application/*,
  aBlock receives the HTTPError about to be signaled, holding the response code and a default message,
  and the response, so it can describe the error: its messageText or additional data.
  Blocks are tried in the order they were registered, before the one for application/json reading
  its message member. Registering a media type again replaces its block."

  | mediaType |
  mediaType := aMediaType asMediaType.
  errorHandlers
    detect: [ :handler | handler key = mediaType ]
    ifFound: [ :handler | handler value: aBlock ]
    ifNone: [ errorHandlers add: mediaType -> aBlock ]
]

{ #category : 'invoking - covenience' }
RESTfulAPIClient >> patch: anEntity at: aLocation withSuccessfulResponseDo: aBlock [

	^ self
		  patchAt: aLocation
		  configuredBy: [ :request | 
			  | command |

			  command := request body contents: anEntity.
			  self withETagAt: aLocation
				  do: [ :entityTag | command := command + ( request headers setIfMatchTo: entityTag asString ) ].
			  command
			  ]
		  withSuccessfulResponseDo: aBlock
]

{ #category : 'invoking' }
RESTfulAPIClient >> patchAt: aLocation configuredBy: aRequestBuildingBlock withSuccessfulResponseDo: aSuccessBlock [

  ^ self handleExceptionsDuring: [
        | httpRequest response |
        httpRequest := HttpRequest patch: aLocation configuredUsing: aRequestBuildingBlock.
        self
          withHttpClientFor: aLocation
          do: [ :httpClient | response := httpRequest applyOn: httpClient ].
        response isSuccess
          ifTrue: [
              expiringCache clearResourceAt: aLocation.
              aSuccessBlock value: ( self tryToCacheContentsOf: response basedOn: aLocation )
            ]
          ifFalse: [
              self
                signalErrorBasedOn: response
                answeredFor: aLocation
                describedByDefaultAs: 'Cannot complete update'
            ]
      ]
]

{ #category : 'invoking - covenience' }
RESTfulAPIClient >> post: anEntity at: aLocation withSuccessfulResponseDo: aBlock [

	^ self
		postAt: aLocation
		configuredBy: [ :request | request body contents: anEntity ]
		withSuccessfulResponseDo: aBlock
]

{ #category : 'invoking' }
RESTfulAPIClient >> postAt: aLocation configuredBy: aRequestBuildingBlock withSuccessfulResponseDo: aBlock [

  ^ self handleExceptionsDuring: [
        | httpRequest response |
        httpRequest := HttpRequest post: aLocation configuredUsing: aRequestBuildingBlock.
        self
          withHttpClientFor: aLocation
          do: [ :httpClient | response := httpRequest applyOn: httpClient ].
        response isSuccess
          ifTrue: [
              expiringCache clearResourceAt: aLocation.
              ( response isCreated and: [ response hasLocation ] ) then: [
                  self tryToCacheContentsOf: response basedOn: response location ].
              aBlock value: response contents
            ]
          ifFalse: [
              self
                signalErrorBasedOn: response
                answeredFor: aLocation
                describedByDefaultAs: 'Cannot complete the request'
            ]
      ]
]

{ #category : 'private - inkoving' }
RESTfulAPIClient >> processPutResponse: response at: aLocation whenSuccessfulDo: aBlock [

  response isSuccess then: [
      expiringCache clearResourceAt: aLocation.
      [ aBlock value: ( self tryToCacheContentsOf: response basedOn: aLocation ) ] unless:
        response isNoContent.
      ^ response
    ].

  ^ self
      signalErrorBasedOn: response
      answeredFor: aLocation
      describedByDefaultAs: 'Cannot complete update'
]

{ #category : 'invoking - covenience' }
RESTfulAPIClient >> put: anEntity at: aLocation [

	^ self
		putAt: aLocation
		configuredBy: [ :request | request body contents: anEntity ]
		withSuccessfulResponseDo: [ :contents | contents ]
]

{ #category : 'invoking' }
RESTfulAPIClient >> putAt: aLocation configuredBy: aRequestBuildingBlock withSuccessfulResponseDo: aBlock [

	^ self
		handleExceptionsDuring: [ | httpRequest response |

			httpRequest := HttpRequest put: aLocation configuredUsing: aRequestBuildingBlock.
			self
				withHttpClientFor: aLocation
				do: [ :httpClient | response := httpRequest applyOn: httpClient ].
			self processPutResponse: response at: aLocation whenSuccessfulDo: aBlock
			]
]

{ #category : 'invoking - covenience' }
RESTfulAPIClient >> query: anEntity at: aLocation accepting: aMediaType withSuccessfulResponseDo: aBlock [

  ^ self
      queryAt: aLocation
      configuredBy: [ :request |
        ( request headers setAcceptTo: aMediaType ) + ( request body contents: anEntity ) ]
      withSuccessfulResponseDo: aBlock
]

{ #category : 'invoking' }
RESTfulAPIClient >> queryAt: aLocation configuredBy: aRequestBuildingBlock withSuccessfulResponseDo: aMonadicBlock [

  | key httpRequest |
  httpRequest := HttpRequest query: aLocation configuredUsing: aRequestBuildingBlock.
  key := ExpiringCacheKeyBuilder keyFor: httpRequest at: aLocation.
  ^ expiringCache
      withResourceAt: key
      obtainedUsing: [
        ZnRequest supportQUERYDuring: [ self execute: httpRequest aimedAt: aLocation ] ]
      do: aMonadicBlock
]

{ #category : 'private - inkoving' }
RESTfulAPIClient >> requestToGet: aLocation configuredUsing: aRequestBuildingBlock [

	^ HttpRequest
		get: aLocation
		configuredUsing: [ :request | 
			self
				addSetIfNoneMatchHeaderTo: aRequestBuildingBlock asHttpRequestCommand
				configuredUsing: request
				ifCached: aLocation
			]
]

{ #category : 'private - exception handling' }
RESTfulAPIClient >> signalErrorBasedOn: aResponse answeredFor: aLocation describedByDefaultAs: aDefaultMessage [

  ^ ( self errorBasedOn: aResponse answeredFor: aLocation describedByDefaultAs: aDefaultMessage )
      signal
]

{ #category : 'private - caching' }
RESTfulAPIClient >> tryToCacheContentsOf: anHttpResponse basedOn: aLocation [

  | contents normalizedLocation |
  contents := anHttpResponse contents.
  normalizedLocation := self normalize: aLocation.

  self
    withEntityTagOf: anHttpResponse
    answeredFor: aLocation
    do: [ :entityTag |
        entityTagByLocationCache at: normalizedLocation put: entityTag.
        anHttpResponse canBeStoredInCache then: [
            lastKnownRepresentationByLocation at: normalizedLocation put: contents ]
      ]
    ifNone: [
        entityTagByLocationCache removeKey: normalizedLocation ifAbsent: [  ].
        lastKnownRepresentationByLocation removeKey: normalizedLocation ifAbsent: [  ]
      ].
  ^ contents
]

{ #category : 'private - exception handling' }
RESTfulAPIClient >> undescribedErrorBasedOn: aResponse withMessage: aMessage [

  | errorClass |
  errorClass := aResponse code > 499
                  ifTrue: [ HTTPServerError ]
                  ifFalse: [ HTTPClientError ].
  ^ ( errorClass code: aResponse code )
      messageText: aMessage;
      yourself
]

{ #category : 'private - caching' }
RESTfulAPIClient >> withCachedETagAt: aLocation do: aBlock [
	"For using the ETag in the `If-None-Match` headers of a GET, we need to have available the last
	representation, just in case the following requests respond with `Not Modified`.
	
	Given than now there's support for `no-store` caching directives, this is not always the case."

	( lastKnownRepresentationByLocation includesKey: ( self normalize: aLocation ) ) then: [
		self withETagAt: aLocation do: aBlock ]
]

{ #category : 'caching' }
RESTfulAPIClient >> withETagAt: aLocation do: aBlock [

	^entityTagByLocationCache at: (self normalize: aLocation) ifPresent: aBlock
]

{ #category : 'private - caching' }
RESTfulAPIClient >> withEntityTagOf: anHttpResponse answeredFor: aLocation do: foundBlock ifNone: noneBlock [
  "An entity tag I cannot read is treated as absent: the request succeeded, so its contents are still answered"

  ^ [ anHttpResponse withEntityTagDo: [ :tag | foundBlock value: tag ] ifAbsent: noneBlock ]
      on: InstanceCreationFailed
      do: [ :error |
          LogRecord emitWarning: ( 'Ignoring the entity tag <1s> answered for <2s>: <3s>'
                expandMacrosWith: ( anHttpResponse headers at: 'ETag' )
                with: aLocation asString
                with: error messageText ).
          error return: noneBlock value
        ]
]

{ #category : 'private - exception handling' }
RESTfulAPIClient >> withErrorHandlerFor: aResponse do: aBlock [

  aResponse contentType ifNotNil: [ :contentType |
      errorHandlers , self defaultErrorHandlers
        detect: [ :handler | contentType matches: handler key ]
        ifFound: [ :handler | aBlock value: handler value ]
        ifNone: [  ]
    ]
]

{ #category : 'private - inkoving' }
RESTfulAPIClient >> withHttpClientFor: aLocation do: aBlock [

	( self clientPoolFor: aLocation ) withPooled: aBlock
]
