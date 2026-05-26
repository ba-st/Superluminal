Class {
	#name : 'RESTfulAPIClient',
	#superclass : 'Object',
	#instVars : [
		'httpClientProvider',
		'httpClientPoolByAuthority',
		'entityTagByLocationCache',
		'lastKnownRepresentationByLocation',
		'expiringCache',
		'httpErrorHandlingPolicy'
	],
	#category : 'Superluminal-RESTfulAPI-Core',
	#package : 'Superluminal-RESTfulAPI',
	#tag : 'Core'
}

{ #category : 'instance creation' }
RESTfulAPIClient class >> buildingHttpClientWith: anHttpClientProvider cachingIn: anExpiringCache [

  ^ self
      buildingHttpClientWith: anHttpClientProvider
      cachingIn: anExpiringCache
      handlingErrorsConfiguredBy: [ :apiClient |
          apiClient whenReceivingMediaType: ZnMimeType applicationJson extractMessageApplying: [ :response |
              | message |
              message := 'Cannot complete the request'.
              response contents ifNotNil: [ :contents |
                  ( NeoJSONObject fromString: contents ) message ifNotNil: [ :m | message := m ] ].
              message
            ]
        ]
]

{ #category : 'instance creation' }
RESTfulAPIClient class >> buildingHttpClientWith: anHttpClientProvider cachingIn: anExpiringCache handlingErrorsConfiguredBy: aBlock [

  ^ self new
      initializeBuildingHttpClientWith: anHttpClientProvider
      cachingIn: anExpiringCache
      handlingErrorsAccordingTo: aBlock
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
        response isSuccess
          ifTrue: [
              expiringCache clearResourceAt: aLocation.
              aBlock cull: ( self tryToCacheContentsOf: response basedOn: aLocation )
            ]
          ifFalse: [ self signalCannotCompleteDeleteErrorBasedOn: response ]
      ]
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
                                raiseErrorBasedOn: response
                                defaultingTo: 'Cannot complete the request' ]
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

{ #category : 'private - exception handling' }
RESTfulAPIClient >> httpErrorClassBasedOn: aResponse [

  ^ aResponse code > 499
      ifTrue: [ HTTPServerError ]
      ifFalse: [ HTTPClientError ]
]

{ #category : 'initialization' }
RESTfulAPIClient >> initializeBuildingHttpClientWith: anHttpClientProvider cachingIn: anExpiringCache handlingErrorsAccordingTo: aBlock [

  | httpErrorHandlingPolicyBuilder |
  httpClientProvider := anHttpClientProvider.
  httpClientPoolByAuthority := Dictionary new.
  entityTagByLocationCache := Dictionary new.
  lastKnownRepresentationByLocation := Dictionary new.
  expiringCache := anExpiringCache.

  httpErrorHandlingPolicyBuilder := HttpErrorHandlingPolicyBuilder new.
  aBlock cull: httpErrorHandlingPolicyBuilder.
  httpErrorHandlingPolicy := httpErrorHandlingPolicyBuilder build
]

{ #category : 'private - caching' }
RESTfulAPIClient >> lastKnownRepresentationOf: aLocation [

	^ lastKnownRepresentationByLocation at: ( self normalize: aLocation )
]

{ #category : 'private - caching' }
RESTfulAPIClient >> normalize: aLocation [

	^aLocation asString
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
		  self withHttpClientFor: aLocation
			  do: [ :httpClient | response := httpRequest applyOn: httpClient ].
		  response isSuccess
			  ifTrue: [ 
				  expiringCache clearResourceAt: aLocation.
				  aSuccessBlock value: ( self tryToCacheContentsOf: response basedOn: aLocation )
				  ]
			  ifFalse: [ self signalCannotCompleteUpdateErrorBasedOn: response ]
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
          ifFalse: [ self raiseErrorBasedOn: response defaultingTo: 'Cannot complete the request' ]
      ]
]

{ #category : 'private - inkoving' }
RESTfulAPIClient >> processPutResponse: aResponse at: aLocation whenSuccessfulDo: aBlock [

  aResponse isSuccess then: [
      expiringCache clearResourceAt: aLocation.
      [ aBlock value: ( self tryToCacheContentsOf: aResponse basedOn: aLocation ) ] unless:
        aResponse isNoContent.
      ^ aResponse
    ].

  ^ self signalCannotCompleteUpdateErrorBasedOn: aResponse
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

  ^ self handleExceptionsDuring: [
        | httpRequest response |
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

{ #category : 'private - exception handling' }
RESTfulAPIClient >> raiseErrorBasedOn: aResponse defaultingTo: aDefaultMessage [

  | httpErrorClass message |
  httpErrorClass := self httpErrorClassBasedOn: aResponse.
  message := httpErrorHandlingPolicy errorMessageFrom: aResponse ifNone: [ aDefaultMessage ].

  ( httpErrorClass code: aResponse code ) signal: message
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
RESTfulAPIClient >> signalCannotCompleteDeleteErrorBasedOn: aResponse [

  ^ self raiseErrorBasedOn: aResponse defaultingTo: 'Cannot complete delete'
]

{ #category : 'private - exception handling' }
RESTfulAPIClient >> signalCannotCompleteUpdateErrorBasedOn: aResponse [

  ^ self raiseErrorBasedOn: aResponse defaultingTo: 'Cannot complete update'
]

{ #category : 'private - caching' }
RESTfulAPIClient >> tryToCacheContentsOf: aResponse basedOn: aLocation [

  | contents normalizedLocation |
  contents := aResponse contents.
  normalizedLocation := self normalize: aLocation.

  aResponse
    withEntityTagDo: [ :entityTag |
        entityTagByLocationCache at: normalizedLocation put: entityTag.
        aResponse canBeStoredInCache then: [
            lastKnownRepresentationByLocation at: normalizedLocation put: contents ]
      ]
    ifAbsent: [
        entityTagByLocationCache removeKey: normalizedLocation ifAbsent: [  ].
        lastKnownRepresentationByLocation removeKey: normalizedLocation ifAbsent: [  ]
      ].
  ^ contents
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

{ #category : 'private - inkoving' }
RESTfulAPIClient >> withHttpClientFor: aLocation do: aBlock [

	( self clientPoolFor: aLocation ) withPooled: aBlock
]
