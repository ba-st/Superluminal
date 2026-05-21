Class {
	#name : 'RESTfulAPIClientTest',
	#superclass : 'APIClientTest',
	#instVars : [
		'apiClient',
		'resourceIdentifier'
	],
	#category : 'Superluminal-RESTfulAPI-Tests',
	#package : 'Superluminal-RESTfulAPI-Tests'
}

{ #category : 'testing' }
RESTfulAPIClientTest class >> isAbstract [ 

	^  self name = #RESTfulAPIClientTest
]

{ #category : 'accessing' }
RESTfulAPIClientTest >> apiClient [

	^ self subclassResponsibility 
]

{ #category : 'private' }
RESTfulAPIClientTest >> customizedErrorDescription [

  ^ 'Customized description'
]

{ #category : 'private' }
RESTfulAPIClientTest >> jsonErrorPayloadDescribedBy: aMessageString [

  ^ String streamContents: [ :stream |
        ( NeoJSONWriter on: stream ) nextPut: ( NeoJSONObject new
              at: #error put: ( NeoJSONObject new
                    at: #messageText put: aMessageString;
                    yourself );
              yourself )
      ]
]

{ #category : 'private' }
RESTfulAPIClientTest >> jsonOkResponse [

	^ self jsonOkResponseWith: #(1 2 3)
]

{ #category : 'private' }
RESTfulAPIClientTest >> location [

	^ 'http://localhost' asAbsoluteUrl + resourceIdentifier
]

{ #category : 'private' }
RESTfulAPIClientTest >> notFoundJsonResponse [

  ^ ZnResponse
      notFound: self location
      entity:
      ( ZnEntity json: ( self jsonErrorPayloadDescribedBy: self customizedErrorDescription ) )
]

{ #category : 'private' }
RESTfulAPIClientTest >> notFoundResponse [

	^ ZnResponse notFound: self location
]

{ #category : 'running' }
RESTfulAPIClientTest >> setUp [

	super setUp.
	apiClient := self apiClient.
	resourceIdentifier := UUID new asString
]

{ #category : 'running' }
RESTfulAPIClientTest >> tearDown [

	apiClient finalize.
	super tearDown
]

{ #category : 'tests - DELETE' }
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

{ #category : 'tests - DELETE' }
RESTfulAPIClientTest >> testDeleteAtSuccess [

	self configureHttpClientToRespondWith: ZnResponse noContent.
	self shouldnt: [ apiClient deleteAt: self location ] raise: HTTPClientError
]

{ #category : 'tests - DELETE' }
RESTfulAPIClientTest >> testDeleteAtSuccessWhenCached [

	| etagIsSet |

	etagIsSet := false.

	self configureHttpClientToRespondWith: ( ( self jsonOkResponseWith: #( 1 2 3 ) )
			  addCachingDirective: 'Max-Age=60';
			  setEntityTag: '"1"' asEntityTag;
			  yourself ).

	self httpClient whenSend: #setIfMatchTo: evaluate: [ :etag | etagIsSet := etag = '"1"' ].

	apiClient get: self location withSuccessfulResponseDo: [ :contents |  ].

	self configureHttpClientToRespondWith: ZnResponse noContent.
	self shouldnt: [ apiClient deleteAt: self location ] raise: HTTPClientError.
	self assert: etagIsSet
]

{ #category : 'tests - DELETE' }
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

{ #category : 'tests - DELETE' }
RESTfulAPIClientTest >> testDeleteTimeout [

  teachableHttpClient
    whenSend: #response
    evaluate: [ ConnectionTimedOut signal: 'Data receive timed out.' ].

  self
    should: [
        apiClient
          deleteAt: self location
          accepting: 'application/json;version=1.0.0' asMediaType
          withSuccessfulResponseDo: [ :responseContents | self fail ]
      ]
    raise: HTTPServerError gatewayTimeout
    withMessageText: 'Data receive timed out.'
]

{ #category : 'tests - GET' }
RESTfulAPIClientTest >> testGetAcceptingWithSuccessfulResponseDo [

  self configureHttpClientToRespondWith: self jsonOkResponse.

  apiClient
    get: self location
    accepting: 'application/json;version=1.0.0' asMediaType
    withSuccessfulResponseDo: [ :responseContents |
        self
          withJsonFrom: responseContents
          do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
      ]
]

{ #category : 'tests - GET' }
RESTfulAPIClientTest >> testGetCached [

  self configureHttpClientToRespondWith: ( ( self jsonOkResponseWith: #( 1 2 3 ) )
        addCachingDirective: 'Max-Age=60';
        yourself ).

  apiClient get: self location withSuccessfulResponseDo: [ :responseContents |
      self
        withJsonFrom: responseContents
        do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
    ].

  self configureHttpClientToRespondWith: self notFoundResponse.

  apiClient get: self location withSuccessfulResponseDo: [ :responseContents |
      self
        withJsonFrom: responseContents
        do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
    ]
]

{ #category : 'tests - GET' }
RESTfulAPIClientTest >> testGetDifferentAuthorizationsDoNotShareCachedResponse [

  self configureHttpClientToRespondWith: ( ( self jsonOkResponseWith: #( 1 2 3 ) )
        addCachingDirective: 'Max-Age=60';
        yourself ).

  apiClient
    getAt: self location
    configuredBy: [ :request | request headers setAuthorizationTo: 'let me pass' ]
    withSuccessfulResponseDo: [ :responseContents |
        self
          withJsonFrom: responseContents
          do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
      ].

  self configureHttpClientToRespondWith: self unauthorizedResponse.

  self
    should: [
        apiClient
          getAt: self location
          configuredBy: [ :request | request headers setAuthorizationTo: 'stop me' ]
          withSuccessfulResponseDo: [ :responseContents | self fail ]
      ]
    raise: ( HTTPClientError code: 401 )
    withMessageText: 'Cannot complete the request'
]

{ #category : 'tests - GET' }
RESTfulAPIClientTest >> testGetDoNotStoreResponseInCache [

  self configureHttpClientToRespondWith: ( ( self jsonOkResponseWith: #( 1 2 3 ) )
        addCachingDirective: 'no-store';
        yourself ).

  apiClient get: self location withSuccessfulResponseDo: [ :responseContents |
      self
        withJsonFrom: responseContents
        do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
    ].

  self configureHttpClientToRespondWith: self notFoundResponse.

  self
    should: [
      apiClient get: self location withSuccessfulResponseDo: [ :responseContents | self fail ] ]
    raise: HTTPClientError notFound
    withMessageText: 'Cannot complete the request'
]

{ #category : 'tests - GET' }
RESTfulAPIClientTest >> testGetIgnoreETagsWhenDoNotStoreCachingPolicyIsInPlace [

  self configureHttpClientToRespondWith: ( ( self jsonOkResponseWith: #( 1 2 3 ) )
        setEntityTag: '"123"';
        addCachingDirective: 'no-store';
        yourself ).

  apiClient get: self location withSuccessfulResponseDo: [ :responseContents |
      self
        withJsonFrom: responseContents
        do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
    ].

  self configureHttpClientToRespondWith: ( ( self jsonOkResponseWith: #( 1 2 3 ) )
        setEntityTag: '"123"';
        addCachingDirective: 'no-store';
        yourself ).

  apiClient get: self location withSuccessfulResponseDo: [ :responseContents |
      self
        withJsonFrom: responseContents
        do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
    ]
]

{ #category : 'tests - GET' }
RESTfulAPIClientTest >> testGetNotFound [

  self configureHttpClientToRespondWith: self notFoundResponse.

  self
    should: [
      apiClient get: self location withSuccessfulResponseDo: [ :responseContents | self fail ] ]
    raise: HTTPClientError notFound
    withMessageText: 'Cannot complete the request'
]

{ #category : 'tests - GET' }
RESTfulAPIClientTest >> testGetNotFoundUsingCustomErrorHandlingBasedOnResponseMediaType [

  apiClient
    forErrorResponsesTyped: ZnMimeType applicationJson
    extractErrorDescriptionWith: [ :response |
      ( NeoJSONObject fromString: response contents ) atPath: #( error messageText ) ].

  self configureHttpClientToRespondWith: self notFoundJsonResponse.

  self
    should: [
      apiClient get: self location withSuccessfulResponseDo: [ :responseContents | self fail ] ]
    raise: HTTPClientError notFound
    withMessageText: self customizedErrorDescription
]

{ #category : 'tests - GET' }
RESTfulAPIClientTest >> testGetTimeout [

  teachableHttpClient
    whenSend: #response
    evaluate: [ ConnectionTimedOut signal: 'Data receive timed out.' ].

  self
    should: [
      apiClient get: self location withSuccessfulResponseDo: [ :responseContents | self fail ] ]
    raise: HTTPServerError gatewayTimeout
    withMessageText: 'Data receive timed out.'
]

{ #category : 'tests - GET' }
RESTfulAPIClientTest >> testGetUsingETagInASecondInvocation [

  | ifNoneMatchHeaderWasSet |
  self configureHttpClientToRespondWith: ( ( self jsonOkResponseWith: #( 1 2 3 ) )
        setEntityTag: '"123"';
        yourself ).

  apiClient get: self location withSuccessfulResponseDo: [ :responseContents |
      self
        withJsonFrom: responseContents
        do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
    ].

  self configureHttpClientToRespondWith: ZnResponse notModified.

  ifNoneMatchHeaderWasSet := false.
  self httpClient whenSend: #setIfNoneMatchTo: evaluate: [ :etag |
      self assert: etag equals: '"123"' asEntityTag.
      ifNoneMatchHeaderWasSet := true
    ].

  apiClient get: self location withSuccessfulResponseDo: [ :responseContents |
      self
        withJsonFrom: responseContents
        do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
    ].

  self assert: ifNoneMatchHeaderWasSet
]

{ #category : 'tests - GET' }
RESTfulAPIClientTest >> testGetWithSuccessfulResponseDo [

  self configureHttpClientToRespondWith: self jsonOkResponse.

  apiClient get: self location withSuccessfulResponseDo: [ :responseContents |
      self
        withJsonFrom: responseContents
        do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
    ]
]

{ #category : 'tests - PATCH' }
RESTfulAPIClientTest >> testPatchAtNoContent [

	self configureHttpClientToRespondWith: ZnResponse noContent.
	apiClient
		patch: ( ZnEntity json: '[]' )
		at: self location
		withSuccessfulResponseDo: [ :responseContents | self assert: responseContents isNil ]
]

{ #category : 'tests - PATCH' }
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

{ #category : 'tests - PATCH' }
RESTfulAPIClientTest >> testPatchAtWithSuccessfulResponseDo [

	self configureHttpClientToRespondWith: self jsonOkResponse.

	apiClient
		patch: ( ZnEntity json: '[]' )
		at: self location
		withSuccessfulResponseDo: [ :responseContents |
			self
				withJsonFrom: responseContents
				do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
			]
]

{ #category : 'tests - PATCH' }
RESTfulAPIClientTest >> testPatchTimeout [

  teachableHttpClient
    whenSend: #response
    evaluate: [ ConnectionTimedOut signal: 'Data receive timed out.' ].

  self
    should: [
        apiClient
          patch: ( ZnEntity json: '[]' )
          at: self location
          withSuccessfulResponseDo: [ :response | self fail ]
      ]
    raise: HTTPServerError gatewayTimeout
    withMessageText: 'Data receive timed out.'
]

{ #category : 'tests - POST' }
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

{ #category : 'tests - POST' }
RESTfulAPIClientTest >> testPostTimeout [

  teachableHttpClient
    whenSend: #response
    evaluate: [ ConnectionTimedOut signal: 'Data receive timed out.' ].

  self
    should: [
        apiClient
          post: ( ZnEntity json: '["hi"]' )
          at: self location
          withSuccessfulResponseDo: [ self fail ]
      ]
    raise: HTTPServerError gatewayTimeout
    withMessageText: 'Data receive timed out.'
]

{ #category : 'tests - POST' }
RESTfulAPIClientTest >> testPostWithSuccessfulResponseDo [

	self configureHttpClientToRespondWith: ( ZnResponse created: self location ).
	apiClient
		post: ( ZnEntity json: '[]' )
		at: self location
		withSuccessfulResponseDo: [ :responseContents | self assert: ( responseContents beginsWith: 'Created' ) ]
]

{ #category : 'tests - PUT' }
RESTfulAPIClientTest >> testPutAt [

	| response |

	self configureHttpClientToRespondWith: self jsonOkResponse.

	response := apiClient put: ( ZnEntity json: '["hi"]' ) at: self location.

	self
		withJsonFrom: response contents
		do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
]

{ #category : 'tests - PUT' }
RESTfulAPIClientTest >> testPutAtNoContent [

	| response |

	self configureHttpClientToRespondWith: ZnResponse noContent.
	response := apiClient put: ( ZnEntity json: '["hi"]' ) at: self location.

	self assert: response isNoContent
]

{ #category : 'tests - PUT' }
RESTfulAPIClientTest >> testPutAtNotFound [

	self configureHttpClientToRespondWith: self notFoundResponse.
	self
		should: [ apiClient put: ( ZnEntity json: '["hi"]' ) at: self location ]
		raise: HTTPClientError notFound
		withMessageText: 'Cannot complete update'
]

{ #category : 'tests - PUT' }
RESTfulAPIClientTest >> testPutTimeout [

  teachableHttpClient
    whenSend: #response
    evaluate: [ ConnectionTimedOut signal: 'Data receive timed out.' ].

  self
    should: [ apiClient put: ( ZnEntity json: '["hi"]' ) at: self location ]
    raise: HTTPServerError gatewayTimeout
    withMessageText: 'Data receive timed out.'
]

{ #category : 'tests - QUERY' }
RESTfulAPIClientTest >> testQueryAtAcceptingWithSuccessfulResponseDo [

  self configureHttpClientToRespondWith: self jsonOkResponse.
  apiClient
    query: ( ZnEntity json: '[]' )
    at: self location
    accepting: 'application/json;version=1.0.0' asMediaType
    withSuccessfulResponseDo: [ :responseContents |
        self
          withJsonFrom: responseContents
          do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
      ]
]

{ #category : 'tests - QUERY' }
RESTfulAPIClientTest >> testQueryBadRequest [

  self configureHttpClientToRespondWith:
    ( ZnResponse badRequest: '' entity: ( ZnEntity text: 'COVID-19' ) ).
  self
    should: [
        apiClient
          query: ( ZnEntity json: '["hi"]' )
          at: self location
          accepting: 'application/json;version=1.0.0' asMediaType
          withSuccessfulResponseDo: [ self fail ]
      ]
    raise: HTTPClientError badRequest
    withMessageText: 'Cannot complete the request'
]

{ #category : 'tests - QUERY' }
RESTfulAPIClientTest >> testQueryCacheDependsOnBody [

  self configureHttpClientToRespondWith: ( ( self jsonOkResponseWith: #( 1 2 3 ) )
        addCachingDirective: 'Max-Age=60';
        yourself ).

  apiClient
    query: ( ZnEntity json: '{"name":"original"}' )
    at: self location
    accepting: 'application/json;version=1.0.0' asMediaType
    withSuccessfulResponseDo: [ :responseContents |
        self
          withJsonFrom: responseContents
          do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
      ].

  self configureHttpClientToRespondWith: self notFoundResponse.

  self
    should: [
        apiClient
          query: ( ZnEntity json: '{"name":"variation"}' )
          at: self location
          accepting: 'application/json;version=1.0.0' asMediaType
          withSuccessfulResponseDo: [ :responseContents | self fail ]
      ]
    raise: HTTPClientError notFound
    withMessageText: 'Cannot complete the request'
]

{ #category : 'tests - QUERY' }
RESTfulAPIClientTest >> testQueryCached [

  self configureHttpClientToRespondWith: ( ( self jsonOkResponseWith: #( 1 2 3 ) )
        addCachingDirective: 'Max-Age=60';
        yourself ).

  apiClient
    query: ( ZnEntity json: '{"name":"original"}' )
    at: self location
    accepting: 'application/json;version=1.0.0' asMediaType
    withSuccessfulResponseDo: [ :responseContents |
        self
          withJsonFrom: responseContents
          do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
      ].

  self configureHttpClientToRespondWith: self notFoundResponse.

  apiClient
    query: ( ZnEntity json: '{"name":"original"}' )
    at: self location
    accepting: 'application/json;version=1.0.0' asMediaType
    withSuccessfulResponseDo: [ :responseContents |
        self
          withJsonFrom: responseContents
          do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
      ]
]

{ #category : 'tests - QUERY' }
RESTfulAPIClientTest >> testQueryDifferentAuthorizationsDoNotShareCachedResponse [

  self configureHttpClientToRespondWith: ( ( self jsonOkResponseWith: #( 1 2 3 ) )
        addCachingDirective: 'Max-Age=60';
        yourself ).

  apiClient
    queryAt: self location
    configuredBy: [ :request |
        ( request headers setAuthorizationTo: 'let me pass' )
        + ( request body contents: ( ZnEntity json: '{"name":"original"}' ) )
      ]
    withSuccessfulResponseDo: [ :responseContents |
        self
          withJsonFrom: responseContents
          do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
      ].

  self configureHttpClientToRespondWith: self unauthorizedResponse.

  self
    should: [
        apiClient
          queryAt: self location
          configuredBy: [ :request |
              ( request headers setAuthorizationTo: 'stop me' )
              + ( request body contents: ( ZnEntity json: '{"name":"original"}' ) )
            ]
          withSuccessfulResponseDo: [ :responseContents | self fail ]
      ]
    raise: ( HTTPClientError code: 401 )
    withMessageText: 'Cannot complete the request'
]

{ #category : 'tests - QUERY' }
RESTfulAPIClientTest >> testQueryDoNotStoreResponseInCache [

  self configureHttpClientToRespondWith: ( ( self jsonOkResponseWith: #( 1 2 3 ) )
        addCachingDirective: 'no-store';
        yourself ).

  apiClient
    query: ( ZnEntity json: '{"name":"original"}' )
    at: self location
    accepting: 'application/json;version=1.0.0' asMediaType
    withSuccessfulResponseDo: [ :responseContents |
        self
          withJsonFrom: responseContents
          do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
      ].

  self configureHttpClientToRespondWith: self notFoundResponse.

  self
    should: [
        apiClient
          query: ( ZnEntity json: '{"name":"original"}' )
          at: self location
          accepting: 'application/json;version=1.0.0' asMediaType
          withSuccessfulResponseDo: [
            apiClient get: self location withSuccessfulResponseDo: [ :responseContents | self fail ] ]
      ]
    raise: HTTPClientError notFound
    withMessageText: 'Cannot complete the request'
]

{ #category : 'tests - QUERY' }
RESTfulAPIClientTest >> testQueryEntityMustBeString [

  self configureHttpClientToRespondWith: ( ( self jsonOkResponseWith: #( 1 2 3 ) )
        addCachingDirective: 'Max-Age=60';
        yourself ).

  self
    should: [
        apiClient
          query: ( ZnEntity bytes:
                ( ByteArray streamContents: [ :out | 32 timesRepeat: [ out nextPut: 255 atRandom ] ] ) )
          at: self location
          accepting: 'application/json;version=1.0.0' asMediaType
          withSuccessfulResponseDo: [ :responseContents | self fail ]
      ]
    raise: HTTPClientError badRequest
    withMessageText: 'Entity to cache can''t be binary'
]

{ #category : 'tests - QUERY' }
RESTfulAPIClientTest >> testQueryIgnoreETagsWhenDoNotStoreCachingPolicyIsInPlace [

  self configureHttpClientToRespondWith: ( ( self jsonOkResponseWith: #( 1 2 3 ) )
        setEntityTag: '"123"';
        addCachingDirective: 'no-store';
        yourself ).

  apiClient
    query: ( ZnEntity json: '{"name":"original"}' )
    at: self location
    accepting: 'application/json;version=1.0.0' asMediaType
    withSuccessfulResponseDo: [ :responseContents |
        self
          withJsonFrom: responseContents
          do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
      ].

  self configureHttpClientToRespondWith: ( ( self jsonOkResponseWith: #( 1 2 3 ) )
        setEntityTag: '"123"';
        addCachingDirective: 'no-store';
        yourself ).

  apiClient
    query: ( ZnEntity json: '{"name":"original"}' )
    at: self location
    accepting: 'application/json;version=1.0.0' asMediaType
    withSuccessfulResponseDo: [ :responseContents |
        self
          withJsonFrom: responseContents
          do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
      ]
]

{ #category : 'tests - QUERY' }
RESTfulAPIClientTest >> testQueryNotFound [

  self configureHttpClientToRespondWith: self notFoundResponse.

  self
    should: [
        apiClient
          query: ( ZnEntity json: '{"name":"original"}' )
          at: self location
          accepting: 'application/json;version=1.0.0' asMediaType
          withSuccessfulResponseDo: [ :responseContents | self fail ]
      ]
    raise: HTTPClientError notFound
    withMessageText: 'Cannot complete the request'
]

{ #category : 'tests - QUERY' }
RESTfulAPIClientTest >> testQueryTimeout [

  teachableHttpClient
    whenSend: #response
    evaluate: [ ConnectionTimedOut signal: 'Data receive timed out.' ].

  self
    should: [
        apiClient
          query: ( ZnEntity json: '{"name":"original"}' )
          at: self location
          accepting: 'application/json;version=1.0.0' asMediaType
          withSuccessfulResponseDo: [ :responseContents | self fail ]
      ]
    raise: HTTPServerError gatewayTimeout
    withMessageText: 'Data receive timed out.'
]

{ #category : 'private' }
RESTfulAPIClientTest >> unauthorizedResponse [

  ^ ZnResponse unauthorized
]

{ #category : 'private' }
RESTfulAPIClientTest >> withJsonFrom: aString do: aBlock [

	aBlock value: ( NeoJSONObject fromString: aString )
]
