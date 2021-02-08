Class {
	#name : #RESTfulAPIClientTest,
	#superclass : #APIClientTest,
	#instVars : [
		'apiClient',
		'resourceIdentifier'
	],
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #testing }
RESTfulAPIClientTest class >> isAbstract [ 

	^  self name = #RESTfulAPIClientTest
]

{ #category : #accessing }
RESTfulAPIClientTest >> apiClient [

	^ self subclassResponsibility 
]

{ #category : #tests }
RESTfulAPIClientTest >> jsonOkResponse [

	^ self jsonOkResponseWith: #(1 2 3)
]

{ #category : #private }
RESTfulAPIClientTest >> location [

	^ 'http://localhost' asUrl + resourceIdentifier
]

{ #category : #tests }
RESTfulAPIClientTest >> notFoundResponse [

	^ ZnResponse notFound: self location
]

{ #category : #running }
RESTfulAPIClientTest >> setUp [

	super setUp.
	apiClient := self apiClient.	"( ExpiringCache onDistributedMemoryAt: {'127.0.0.1:11211'} )"
	resourceIdentifier := UUID new asString
]

{ #category : #running }
RESTfulAPIClientTest >> tearDown [

	apiClient finalize.
	super tearDown
]

{ #category : #tests }
RESTfulAPIClientTest >> testDeleteAcceptingWithSuccessfulResponseDo [

	| wasSuccessfull |

	self configureHttpClientToRespondWith: ZnResponse noContent.
	wasSuccessfull := false.
	apiClient
		deleteAt: self location
		accepting: 'application/json;version=1.0.0' asMediaType
		withSuccessfulResponseDo: [ :responseContents | wasSuccessfull := true ].

	self assert: wasSuccessfull
]

{ #category : #tests }
RESTfulAPIClientTest >> testDeleteNotFound [

	self configureHttpClientToRespondWith: self notFoundResponse.

	self
		should: [ apiClient
				deleteAt: self location
				accepting: 'application/json;version=1.0.0' asMediaType
				withSuccessfulResponseDo: [ :responseContents | self fail ]
			]
		raise: HTTPClientError notFound
]

{ #category : #tests }
RESTfulAPIClientTest >> testGetAcceptingWithSuccessfulResponseDo [

	self configureHttpClientToRespondWith: self jsonOkResponse.

	apiClient
		get: self location
		accepting: 'application/json;version=1.0.0' asMediaType
		withSuccessfulResponseDo:
			[ :responseContents | self withJsonFrom: responseContents do: [ :json | self assert: json equals: #(1 2 3) ] ]
]

{ #category : #tests }
RESTfulAPIClientTest >> testGetCached [

	self
		configureHttpClientToRespondWith:
			( ( self jsonOkResponseWith: #(1 2 3) )
				addCachingDirective: 'Max-Age=60';
				yourself ).

	apiClient
		get: self location
		withSuccessfulResponseDo:
			[ :responseContents | self withJsonFrom: responseContents do: [ :json | self assert: json equals: #(1 2 3) ] ].

	self configureHttpClientToRespondWith: ( ZnResponse notFound: self location ).

	apiClient
		get: self location
		withSuccessfulResponseDo:
			[ :responseContents | self withJsonFrom: responseContents do: [ :json | self assert: json equals: #(1 2 3) ] ]
]

{ #category : #tests }
RESTfulAPIClientTest >> testGetNotFound [

	self configureHttpClientToRespondWith: self notFoundResponse.

	self
		should: [ apiClient get: self location withSuccessfulResponseDo: [ :responseContents | self fail ] ]
		raise: HTTPClientError notFound
]

{ #category : #tests }
RESTfulAPIClientTest >> testGetWithSuccessfulResponseDo [

	self configureHttpClientToRespondWith: self jsonOkResponse.

	apiClient
		get: self location
		withSuccessfulResponseDo:
			[ :responseContents | self withJsonFrom: responseContents do: [ :json | self assert: json equals: #(1 2 3) ] ]
]

{ #category : #tests }
RESTfulAPIClientTest >> testPatchAtNoContent [

	self configureHttpClientToRespondWith: ZnResponse noContent.
	apiClient
		patch: ( ZnEntity json: '[]' )
		at: self location
		withSuccessfulResponseDo: [ :responseContents | self assert: responseContents isNil ]
]

{ #category : #tests }
RESTfulAPIClientTest >> testPatchAtNotFound [

	self configureHttpClientToRespondWith: self notFoundResponse.
	self
		should: [ apiClient
				patch: ( ZnEntity json: '[]' )
				at: self location
				withSuccessfulResponseDo: [ :response | self fail ]
			]
		raise: HTTPClientError notFound
		withMessageText: 'Cannot complete update'
]

{ #category : #tests }
RESTfulAPIClientTest >> testPatchAtWithSuccessfulResponseDo [

	self configureHttpClientToRespondWith: self jsonOkResponse.

	apiClient
		patch: ( ZnEntity json: '[]' )
		at: self location
		withSuccessfulResponseDo:
			[ :responseContents | self withJsonFrom: responseContents do: [ :json | self assert: json equals: #(1 2 3) ] ]
]

{ #category : #tests }
RESTfulAPIClientTest >> testPostBadRequest [

	self
		configureHttpClientToRespondWith: ( ZnResponse badRequest: '' entity: ( ZnEntity text: 'COVID-19' ) ).
	self
		should: [ apiClient
				post: ( ZnEntity json: '["hi"]' )
				at: self location
				withSuccessfulResponseDo: [ self fail ]
			]
		raise: HTTPClientError badRequest
		withMessageText: 'Cannot complete the request'
]

{ #category : #tests }
RESTfulAPIClientTest >> testPostWithSuccessfulResponseDo [

	self configureHttpClientToRespondWith: ( ZnResponse created: self location ).
	apiClient
		post: ( ZnEntity json: '[]' )
		at: self location
		withSuccessfulResponseDo: [ :responseContents | self assert: ( responseContents beginsWith: 'Created' ) ]
]

{ #category : #tests }
RESTfulAPIClientTest >> testPutAt [

	| response |

	self configureHttpClientToRespondWith: self jsonOkResponse.

	response := apiClient put: ( ZnEntity json: '["hi"]' ) at: self location.

	self withJsonFrom: response contents do: [ :json | self assert: json equals: #(1 2 3) ]
]

{ #category : #tests }
RESTfulAPIClientTest >> testPutAtNoContent [

	| response |

	self configureHttpClientToRespondWith: ZnResponse noContent.
	response := apiClient put: ( ZnEntity json: '["hi"]' ) at: self location.

	self assert: response isNoContent
]

{ #category : #tests }
RESTfulAPIClientTest >> testPutAtNotFound [

	self configureHttpClientToRespondWith: self notFoundResponse.
	self
		should: [ apiClient put: ( ZnEntity json: '["hi"]' ) at: self location ]
		raise: HTTPClientError notFound
		withMessageText: 'Cannot complete update'
]

{ #category : #private }
RESTfulAPIClientTest >> withJsonFrom: aString do: aBlock [

	aBlock value: ( NeoJSONObject fromString: aString )
]
