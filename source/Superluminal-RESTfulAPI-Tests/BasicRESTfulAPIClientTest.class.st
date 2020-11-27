Class {
	#name : #BasicRESTfulAPIClientTest,
	#superclass : #APIClientTest,
	#instVars : [
		'apiClient'
	],
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #tests }
BasicRESTfulAPIClientTest >> jsonOkResponse [

	^ self jsonOkResponseWith: #(1 2 3)
]

{ #category : #private }
BasicRESTfulAPIClientTest >> location [

	^ 'http://localhost' asUrl
]

{ #category : #tests }
BasicRESTfulAPIClientTest >> notFoundResponse [

	^ ZnResponse notFound: self location
]

{ #category : #running }
BasicRESTfulAPIClientTest >> setUp [

	super setUp.
	apiClient := RESTfulAPIClient buildingHttpClientWith: [ self httpClient ]
]

{ #category : #running }
BasicRESTfulAPIClientTest >> tearDown [

	apiClient finalize.
	super tearDown
]

{ #category : #tests }
BasicRESTfulAPIClientTest >> testDeleteAcceptingWithSuccessfulResponseDo [

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
BasicRESTfulAPIClientTest >> testDeleteNotFound [

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
BasicRESTfulAPIClientTest >> testGetAcceptingWithSuccessfulResponseDo [

	self configureHttpClientToRespondWith: self jsonOkResponse.

	apiClient
		get: self location
		accepting: 'application/json;version=1.0.0' asMediaType
		withSuccessfulResponseDo:
			[ :responseContents | self withJsonFrom: responseContents do: [ :json | self assert: json equals: #(1 2 3) ] ]
]

{ #category : #tests }
BasicRESTfulAPIClientTest >> testGetCached [

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
BasicRESTfulAPIClientTest >> testGetNotFound [

	self configureHttpClientToRespondWith: self notFoundResponse.

	self
		should: [ apiClient get: self location withSuccessfulResponseDo: [ :responseContents | self fail ] ]
		raise: HTTPClientError notFound
]

{ #category : #tests }
BasicRESTfulAPIClientTest >> testGetWithSuccessfulResponseDo [

	self configureHttpClientToRespondWith: self jsonOkResponse.

	apiClient
		get: self location
		withSuccessfulResponseDo:
			[ :responseContents | self withJsonFrom: responseContents do: [ :json | self assert: json equals: #(1 2 3) ] ]
]

{ #category : #tests }
BasicRESTfulAPIClientTest >> testPatchAtNoContent [

	self configureHttpClientToRespondWith: ZnResponse noContent.
	apiClient
		patch: ( ZnEntity json: '[]' )
		at: self location
		withSuccessfulResponseDo: [ :responseContents | self assert: responseContents isNil ]
]

{ #category : #tests }
BasicRESTfulAPIClientTest >> testPatchAtNotFound [

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
BasicRESTfulAPIClientTest >> testPatchAtWithSuccessfulResponseDo [

	self configureHttpClientToRespondWith: self jsonOkResponse.

	apiClient
		patch: ( ZnEntity json: '[]' )
		at: self location
		withSuccessfulResponseDo:
			[ :responseContents | self withJsonFrom: responseContents do: [ :json | self assert: json equals: #(1 2 3) ] ]
]

{ #category : #tests }
BasicRESTfulAPIClientTest >> testPostBadRequest [

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
BasicRESTfulAPIClientTest >> testPostWithSuccessfulResponseDo [

	self configureHttpClientToRespondWith: ( ZnResponse created: self location ).
	apiClient
		post: ( ZnEntity json: '[]' )
		at: self location
		withSuccessfulResponseDo: [ :responseContents | self assert: ( responseContents beginsWith: 'Created' ) ]
]

{ #category : #tests }
BasicRESTfulAPIClientTest >> testPutAt [

	| response |

	self configureHttpClientToRespondWith: self jsonOkResponse.

	response := apiClient put: ( ZnEntity json: '["hi"]' ) at: self location.

	self withJsonFrom: response contents do: [ :json | self assert: json equals: #(1 2 3) ]
]

{ #category : #tests }
BasicRESTfulAPIClientTest >> testPutAtNoContent [

	| response |

	self configureHttpClientToRespondWith: ZnResponse noContent.
	response := apiClient put: ( ZnEntity json: '["hi"]' ) at: self location.

	self assert: response isNoContent
]

{ #category : #tests }
BasicRESTfulAPIClientTest >> testPutAtNotFound [

	self configureHttpClientToRespondWith: self notFoundResponse.
	self
		should: [ apiClient put: ( ZnEntity json: '["hi"]' ) at: self location ]
		raise: HTTPClientError notFound
		withMessageText: 'Cannot complete update'
]

{ #category : #private }
BasicRESTfulAPIClientTest >> withJsonFrom: aString do: aBlock [

	aBlock value: ( NeoJSONObject fromString: aString )
]
