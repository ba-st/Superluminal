Class {
	#name : #RESTfulAPIClient,
	#superclass : #Object,
	#instVars : [
		'httpClientProvider',
		'httpClientPoolByAuthority',
		'entityTagByLocationCache',
		'lastKnownRepresentationByLocation',
		'expiringCache'
	],
	#category : #'Superluminal-RESTfulAPI'
}

{ #category : #'instance creation' }
RESTfulAPIClient class >> buildingHttpClientWith: anHttpClientProvider cachingIn: anExpiringCache [

	^ self new initializeBuildingHttpClientWith: anHttpClientProvider cachingIn: anExpiringCache
]

{ #category : #'instance creation' }
RESTfulAPIClient class >> cachingOnLocalMemory [

	^ self buildingHttpClientWith: [ ZnClient new ] cachingIn: ExpiringCache onLocalMemory
]

{ #category : #'private - caching' }
RESTfulAPIClient >> addSetIfNoneMatchHeaderTo: command configuredUsing: request ifCached: aLocation [

	self
		withCachedETagAt: aLocation
		do: [:entityTag | ^command + (request headers setIfNoneMatchTo: entityTag)].
	^command
]

{ #category : #'private - exception handling' }
RESTfulAPIClient >> clientErrorMessageFrom: response [

	response contentType
		ifNotNil: [ :contentType | 
			( contentType matches: ZnMimeType applicationJson )
				and: [ response contents
						ifNotNil: [ :contents | ( NeoJSONObject fromString: contents ) message ifNotNil: [ :message | ^ message ] ]
					]
			].

	^ 'Cannot complete the request'
]

{ #category : #'private - inkoving' }
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

{ #category : #'invoking - covenience' }
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

{ #category : #'invoking - covenience' }
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

{ #category : #invoking }
RESTfulAPIClient >> deleteAt: aLocation configuredBy: aRequestBuildingBlock withSuccessfulResponseDo: aBlock [

	^ self
		handleExceptionsDuring: [ 
			| httpRequest response |

			httpRequest := HttpRequest delete: aLocation configuredUsing: aRequestBuildingBlock.
			self
				withHttpClientFor: aLocation
				do: [ :httpClient | response := httpRequest applyOn: httpClient ].
			( response isSuccess or: [ response isNoContent ] )
				ifTrue: [ expiringCache clearResourceAt: aLocation.
					aBlock cull: ( self tryToCacheContentsOf: response basedOn: aLocation )
					]
				ifFalse: [ self signalCannotCompleteDeleteErrorBasedOn: response ]
			]
]

{ #category : #finalization }
RESTfulAPIClient >> finalize [

	httpClientPoolByAuthority
		valuesDo: [ :pool | 
			pool
				minIdleObjects: nil;
				clear
			].
	^ super finalize
]

{ #category : #'invoking - covenience' }
RESTfulAPIClient >> get: aLocation accepting: aMediaType withSuccessfulResponseDo: aBlock [

	^ self
		getAt: aLocation
		configuredBy: [ :request | request headers setAcceptTo: aMediaType ]
		withSuccessfulResponseDo: aBlock
]

{ #category : #'private - inkoving' }
RESTfulAPIClient >> get: aLocation executing: httpRequest [

	^ self
		handleExceptionsDuring: [ 
			| response contents |
			self
				withHttpClientFor: aLocation
				do: [ :httpClient | response := httpRequest applyOn: httpClient ].
			contents := response isNotModified
				ifTrue: [ self lastKnownRepresentationOf: aLocation ]
				ifFalse: [ response isSuccess
						ifTrue: [ self tryToCacheContentsOf: response basedOn: aLocation ]
						ifFalse: [ self raiseErrorBasedOn: response ]
					].
			ExpiringResource for: contents controlledBy: response
			]
]

{ #category : #'invoking - covenience' }
RESTfulAPIClient >> get: aLocation withSuccessfulResponseDo: aMonadicBlock [

	^ self getAt: aLocation configuredBy: [  ] withSuccessfulResponseDo: aMonadicBlock
]

{ #category : #invoking }
RESTfulAPIClient >> getAt: aLocation configuredBy: aRequestBuildingBlock withSuccessfulResponseDo: aMonadicBlock [

	| key request |

	request := self requestToGet: aLocation configuredUsing: aRequestBuildingBlock.
	key := ExpiringCacheKeyBuilder keyFor: request at: aLocation.
	^ expiringCache
		withResourceAt: key
		obtainedUsing: [ self get: aLocation executing: request ]
		do: aMonadicBlock
]

{ #category : #'private - exception handling' }
RESTfulAPIClient >> handleExceptionsDuring: anInvokingBlock [

	^ [ anInvokingBlock
		on: NetworkError
		do:
			[ :signal | HTTPServerError signalInternalServerError: 'Cannot complete the request due to some network error' ]
	]
		on: AssertionFailed , InstanceCreationFailed , NeoJSONMappingNotFound , NeoJSONParseError
		do: [ :signal | HTTPClientError badRequest signal: signal messageText ]
]

{ #category : #initialization }
RESTfulAPIClient >> initializeBuildingHttpClientWith: anHttpClientProvider cachingIn: anExpiringCache [

	httpClientProvider := anHttpClientProvider.
	httpClientPoolByAuthority := Dictionary new.
	entityTagByLocationCache := Dictionary new.
	lastKnownRepresentationByLocation := Dictionary new.
	expiringCache := anExpiringCache
]

{ #category : #'private - caching' }
RESTfulAPIClient >> lastKnownRepresentationOf: aLocation [

	^ lastKnownRepresentationByLocation at: ( self normalize: aLocation )
]

{ #category : #'private - caching' }
RESTfulAPIClient >> normalize: aLocation [

	^aLocation asString
]

{ #category : #'invoking - covenience' }
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

{ #category : #invoking }
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

{ #category : #'invoking - covenience' }
RESTfulAPIClient >> post: anEntity at: aLocation withSuccessfulResponseDo: aBlock [

	^ self
		postAt: aLocation
		configuredBy: [ :request | request body contents: anEntity ]
		withSuccessfulResponseDo: aBlock
]

{ #category : #invoking }
RESTfulAPIClient >> postAt: aLocation configuredBy: aRequestBuildingBlock withSuccessfulResponseDo: aBlock [

	^ self
		handleExceptionsDuring: [ 
			| httpRequest response |
			httpRequest := HttpRequest post: aLocation configuredUsing: aRequestBuildingBlock.
			self
				withHttpClientFor: aLocation
				do: [ :httpClient | response := httpRequest applyOn: httpClient ].
			response isSuccess
				ifTrue: [ expiringCache clearResourceAt: aLocation.
					( response isCreated and: [ response hasLocation ] )
						then: [ self tryToCacheContentsOf: response basedOn: response location ].
					aBlock value: response contents
					]
				ifFalse: [ ( HTTPClientError code: response code ) signal: ( self clientErrorMessageFrom: response ) ]
			]
]

{ #category : #'private - inkoving' }
RESTfulAPIClient >> processPutResponse: response at: aLocation whenSuccessfulDo: aBlock [

	response isSuccess
		then: [ 
			expiringCache clearResourceAt: aLocation.
			^ response isNoContent
				then: [ response ]
				otherwise: [ aBlock value: ( self tryToCacheContentsOf: response basedOn: aLocation ) ]
			].

	^ self signalCannotCompleteUpdateErrorBasedOn: response
]

{ #category : #'invoking - covenience' }
RESTfulAPIClient >> put: anEntity at: aLocation [

	^ self
		putAt: aLocation
		configuredBy: [ :request | request body contents: anEntity ]
		withSuccessfulResponseDo: [ :contents | contents ]
]

{ #category : #invoking }
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

{ #category : #'private - inkoving' }
RESTfulAPIClient >> raiseErrorBasedOn: httpResponse [

	| message httpErrorClass |

	message := [ ( NeoJSONObject fromString: httpResponse contents ) at: #message ]
		on: Error
		do: [ :aSignal | aSignal return: 'Cannot complete the request' ].
	httpErrorClass := httpResponse code > 499
		ifTrue: [ HTTPServerError ]
		ifFalse: [ HTTPClientError ].
	( httpErrorClass code: httpResponse code ) signal: message
]

{ #category : #'private - inkoving' }
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

{ #category : #'private - exception handling' }
RESTfulAPIClient >> signalCannotCompleteDeleteErrorBasedOn: response [

	^ ( HTTPClientError code: response code ) signal: 'Cannot complete delete'
]

{ #category : #'private - exception handling' }
RESTfulAPIClient >> signalCannotCompleteUpdateErrorBasedOn: response [

	^ ( HTTPClientError code: response code ) signal: 'Cannot complete update'
]

{ #category : #'private - caching' }
RESTfulAPIClient >> tryToCacheContentsOf: anHttpResponse basedOn: aLocation [

	| contents normalizedLocation |

	contents := anHttpResponse contents.
	normalizedLocation := self normalize: aLocation.

	anHttpResponse
		withEntityTagDo: [ :entityTag |
			entityTagByLocationCache at: normalizedLocation put: entityTag.
			anHttpResponse canBeStoredInCache then: [
				lastKnownRepresentationByLocation at: normalizedLocation put: contents ]
			]
		ifAbsent: [
			entityTagByLocationCache removeKey: normalizedLocation ifAbsent: [  ].
			lastKnownRepresentationByLocation removeKey: normalizedLocation ifAbsent: [  ]
			].
	^ contents
]

{ #category : #'private - caching' }
RESTfulAPIClient >> withCachedETagAt: aLocation do: aBlock [
	"For using the ETag in the `If-None-Match` headers of a GET, we need to have available the last
	representation, just in case the following requests respond with `Not Modified`.
	
	Given than now there's support for `no-store` caching directives, this is not allways the case."

	( lastKnownRepresentationByLocation includesKey: ( self normalize: aLocation ) ) then: [
		self withETagAt: aLocation do: aBlock ]
]

{ #category : #'private - caching' }
RESTfulAPIClient >> withETagAt: aLocation do: aBlock [

	^entityTagByLocationCache at: (self normalize: aLocation) ifPresent: aBlock
]

{ #category : #'private - inkoving' }
RESTfulAPIClient >> withHttpClientFor: aLocation do: aBlock [

	( self clientPoolFor: aLocation ) withPooled: aBlock
]
