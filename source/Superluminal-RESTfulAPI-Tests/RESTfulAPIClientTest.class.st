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
RESTfulAPIClientTest >> everyMethodWithItsDefaultErrorDescriptionDo: aBlock [

  aBlock
    value: [ apiClient get: self location withSuccessfulResponseDo: [ :contents | self fail ] ]
    value: 'Cannot complete the request'.
  aBlock
    value: [
        apiClient
          query: ( ZnEntity json: '["hi"]' )
          at: self location
          accepting: ZnMimeType applicationJson
          withSuccessfulResponseDo: [ :contents | self fail ]
      ]
    value: 'Cannot complete the request'.
  aBlock
    value: [
        apiClient
          post: ( ZnEntity json: '["hi"]' )
          at: self location
          withSuccessfulResponseDo: [ :contents | self fail ]
      ]
    value: 'Cannot complete the request'.
  aBlock
    value: [ apiClient put: ( ZnEntity json: '["hi"]' ) at: self location ]
    value: 'Cannot complete update'.
  aBlock
    value: [
        apiClient
          patch: ( ZnEntity json: '["hi"]' )
          at: self location
          withSuccessfulResponseDo: [ :contents | self fail ]
      ]
    value: 'Cannot complete update'.
  aBlock value: [ apiClient deleteAt: self location ] value: 'Cannot complete delete'
]

{ #category : 'private' }
RESTfulAPIClientTest >> jsonOkResponse [

	^ self jsonOkResponseWith: #(1 2 3)
]

{ #category : 'private' }
RESTfulAPIClientTest >> jsonOkResponseWithUnreadableEntityTag [

  | response |
  response := self jsonOkResponse.
  response headers at: 'ETag' put: '"1 2 3"'.
  ^ response
]

{ #category : 'private' }
RESTfulAPIClientTest >> location [

	^ 'http://localhost' asAbsoluteUrl + resourceIdentifier
]

{ #category : 'private' }
RESTfulAPIClientTest >> notFoundResponse [

	^ ZnResponse notFound: self location
]

{ #category : 'private' }
RESTfulAPIClientTest >> responseCoded: aCode containing: aString typed: aMediaType [

  ^ ( ZnResponse statusCode: aCode )
      entity: ( ZnEntity with: aString type: aMediaType asMediaType );
      yourself
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

{ #category : 'tests - errors' }
RESTfulAPIClientTest >> testErrorsDescribedByACustomMediaType [

  apiClient onErrorsTyped: 'application/vnd.superluminal.error+json' do: [ :error :response |
      | json |
      json := NeoJSONObject fromString: response contents.
      error
        messageText: ( json at: #summary );
        additionalDataAt: #reasons put: ( json at: #reasons ) asArray
    ].
  self configureHttpClientToRespondWith: ( self
        responseCoded: 422
        containing: '{"summary":"Invalid pet","reasons":["The name is required"]}'
        typed: 'application/vnd.superluminal.error+json' ).

  self everyMethodWithItsDefaultErrorDescriptionDo: [ :invocation :defaultDescription |
      self
        should: invocation
        raise: HTTPClientError unprocessableEntity
        withExceptionDo: [ :error |
            self
              assert: error messageText equals: 'Invalid pet';
              assert: ( error additionalDataAt: #reasons ) equals: #( 'The name is required' )
          ]
    ]
]

{ #category : 'tests - errors' }
RESTfulAPIClientTest >> testErrorsDescribedByAMediaTypePattern [

  apiClient onErrorsTyped: 'text/*' do: [ :error :response | error messageText: response contents ].
  self configureHttpClientToRespondWith:
    ( self responseCoded: 503 containing: 'Down for maintenance' typed: ZnMimeType textPlain ).

  self everyMethodWithItsDefaultErrorDescriptionDo: [ :invocation :defaultDescription |
      self
        should: invocation
        raise: HTTPServerError serviceUnavailable
        withMessageText: 'Down for maintenance'
    ]
]

{ #category : 'tests - errors' }
RESTfulAPIClientTest >> testErrorsDescribedByProblemDetails [

  apiClient handleErrorsTypedAsProblemDetails.
  self configureHttpClientToRespondWith: ( self
        responseCoded: 422
        containing:
        '{"type":"https://example.com/probs/out-of-credit","title":"You do not have enough credit.","status":422,"detail":"Your current balance is 30, but that costs 50.","instance":"/account/12345/msgs/abc","balance":30,"accounts":["/account/12345","/account/67890"]}'
        typed: 'application/problem+json' ).

  self everyMethodWithItsDefaultErrorDescriptionDo: [ :invocation :defaultDescription |
      self
        should: invocation
        raise: HTTPClientError unprocessableEntity
        withExceptionDo: [ :error |
            self
              assert: error messageText equals: 'Your current balance is 30, but that costs 50.';
              assert: ( error additionalDataAt: #type )
              equals: 'https://example.com/probs/out-of-credit';
              assert: ( error additionalDataAt: #title ) equals: 'You do not have enough credit.';
              assert: ( error additionalDataAt: #instance ) equals: '/account/12345/msgs/abc';
              assert: ( error additionalDataAt: #balance ) equals: 30;
              assert: ( error additionalDataAt: #accounts ) asArray
              equals: #( '/account/12345' '/account/67890' );
              should: [ error additionalDataAt: #detail ] raise: KeyNotFound;
              should: [ error additionalDataAt: #status ] raise: KeyNotFound
          ]
    ]
]

{ #category : 'tests - errors' }
RESTfulAPIClientTest >> testErrorsDescribedByTheJSONMessage [

  self configureHttpClientToRespondWith: ( self
        responseCoded: 404
        containing: '{"code":404,"message":"Pet not found"}'
        typed: ZnMimeType applicationJson ).

  self everyMethodWithItsDefaultErrorDescriptionDo: [ :invocation :defaultDescription |
      self should: invocation raise: HTTPClientError notFound withMessageText: 'Pet not found' ]
]

{ #category : 'tests - errors' }
RESTfulAPIClientTest >> testErrorsTypedAsJSONWithoutMessage [

  self configureHttpClientToRespondWith:
    ( self responseCoded: 404 containing: '{"code":404}' typed: ZnMimeType applicationJson ).

  self everyMethodWithItsDefaultErrorDescriptionDo: [ :invocation :defaultDescription |
      self should: invocation raise: HTTPClientError notFound withMessageText: defaultDescription ]
]

{ #category : 'tests - errors' }
RESTfulAPIClientTest >> testErrorsTypedAsJSONWithoutAStringMessage [

  #( '{"code":404,"message":null}' '{"code":404,"message":42}' ) do: [ :json |
      self configureHttpClientToRespondWith:
        ( self responseCoded: 404 containing: json typed: ZnMimeType applicationJson ).

      self everyMethodWithItsDefaultErrorDescriptionDo: [ :invocation :defaultDescription |
          self
            should: invocation
            raise: HTTPClientError notFound
            withMessageText: defaultDescription ]
    ]
]

{ #category : 'tests - errors' }
RESTfulAPIClientTest >> testErrorsWithAnUnreadableJSONBody [

  self configureHttpClientToRespondWith:
    ( self responseCoded: 503 containing: 'Service Unavailable' typed: ZnMimeType applicationJson ).

  self everyMethodWithItsDefaultErrorDescriptionDo: [ :invocation :defaultDescription |
      self
        should: invocation
        raise: HTTPServerError serviceUnavailable
        withMessageText: defaultDescription
    ]
]

{ #category : 'tests - errors' }
RESTfulAPIClientTest >> testFailingErrorDescriptionIsIgnored [

  | loggingAsserter |
  apiClient onErrorsTyped: ZnMimeType textPlain do: [ :error :response |
      error additionalDataAt: #partial put: true.
      AssertionFailed signal: 'Unexpected payload'
    ].
  self configureHttpClientToRespondWith: self notFoundResponse.
  loggingAsserter := LoggingAsserter on: self.

  [
    loggingAsserter runMemoryLoggerDuring: [
        self
          should: [
            apiClient get: self location withSuccessfulResponseDo: [ :contents | self fail ] ]
          raise: HTTPClientError notFound
          withExceptionDo: [ :error |
              self
                assert: error messageText equals: 'Cannot complete the request';
                deny: error hasAdditionalData
            ]
      ].
    loggingAsserter assertLogRecordsMatch:
      { 'Ignoring the description of the 404 error answered for ' , self location asString
        , ': Unexpected payload' }
  ] ensure: [ loggingAsserter stopLoggers ]
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
RESTfulAPIClientTest >> testGetCachedWithQuotedMaxAge [

  self configureHttpClientToRespondWithAll: { self jsonOkResponse
        addCachingDirective: 'max-age="60"';
        yourself . self notFoundResponse }.

  2 timesRepeat: [
      apiClient get: self location withSuccessfulResponseDo: [ :responseContents |
          self
            withJsonFrom: responseContents
            do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
        ]
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
RESTfulAPIClientTest >> testGetForgetsTheCachedEntityTagWhenAnsweredAnUnreadableOne [

  | entityTagsSent responseWithEntityTag |
  entityTagsSent := OrderedCollection new.
  self httpClient
    whenSend: #setIfNoneMatchTo:
    evaluate: [ :entityTag | entityTagsSent add: entityTag ].
  responseWithEntityTag := self jsonOkResponse.
  responseWithEntityTag setEntityTag: '"123"'.
  self configureHttpClientToRespondWithAll:
    { responseWithEntityTag . self jsonOkResponseWithUnreadableEntityTag .
      self jsonOkResponse }.

  3 timesRepeat: [ apiClient get: self location withSuccessfulResponseDo: [ :responseContents |  ] ].

  self assert: entityTagsSent asArray equals: { '"123"' asEntityTag }
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
RESTfulAPIClientTest >> testGetIgnoringAnUnreadableEntityTag [

  | loggingAsserter |
  loggingAsserter := LoggingAsserter on: self.
  self configureHttpClientToRespondWith: self jsonOkResponseWithUnreadableEntityTag.

  [
    loggingAsserter runMemoryLoggerDuring: [
        apiClient get: self location withSuccessfulResponseDo: [ :responseContents |
            self
              withJsonFrom: responseContents
              do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
          ]
      ].
    loggingAsserter assertLogRecordsMatch:
      { 'Ignoring the entity tag "1 2 3" answered for ' , self location asString }
  ] ensure: [ loggingAsserter stopLoggers ]
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
RESTfulAPIClientTest >> testGetWithMalformedMaxAge [

  self configureHttpClientToRespondWithAll: { self jsonOkResponse
        addCachingDirective: 'max-age=abc';
        yourself . self notFoundResponse }.

  apiClient get: self location withSuccessfulResponseDo: [ :responseContents |
      self
        withJsonFrom: responseContents
        do: [ :json | self assert: json hasTheSameElementsInTheSameOrderThat: #( 1 2 3 ) ]
    ].

  self
    should: [
      apiClient get: self location withSuccessfulResponseDo: [ :responseContents | self fail ] ]
    raise: HTTPClientError notFound
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

{ #category : 'tests - errors' }
RESTfulAPIClientTest >> testProblemDetailsAreOnlyDescribedWhenRequested [

  self configureHttpClientToRespondWith: ( self
        responseCoded: 422
        containing: '{"type":"about:blank","title":"Invalid pet","status":422}'
        typed: 'application/problem+json' ).

  self everyMethodWithItsDefaultErrorDescriptionDo: [ :invocation :defaultDescription |
      self
        should: invocation
        raise: HTTPClientError unprocessableEntity
        withExceptionDo: [ :error |
            self
              assert: error messageText equals: defaultDescription;
              deny: error hasAdditionalData
          ]
    ]
]

{ #category : 'tests - errors' }
RESTfulAPIClientTest >> testProblemDetailsWithoutDetailAreDescribedByTheirTitle [

  apiClient handleErrorsTypedAsProblemDetails.
  self configureHttpClientToRespondWith: ( self
        responseCoded: 503
        containing: '{"type":"about:blank","title":"Down for maintenance","status":503}'
        typed: 'application/problem+json' ).

  self everyMethodWithItsDefaultErrorDescriptionDo: [ :invocation :defaultDescription |
      self
        should: invocation
        raise: HTTPServerError serviceUnavailable
        withMessageText: 'Down for maintenance'
    ]
]

{ #category : 'tests - errors' }
RESTfulAPIClientTest >> testProblemDetailsWithoutTextualDescription [

  apiClient handleErrorsTypedAsProblemDetails.
  self configureHttpClientToRespondWith: ( self
        responseCoded: 404
        containing: '{"type":"https://example.com/probs/gone","title":404,"status":404}'
        typed: 'application/problem+json' ).

  self everyMethodWithItsDefaultErrorDescriptionDo: [ :invocation :defaultDescription |
      self should: invocation raise: HTTPClientError notFound withExceptionDo: [ :error |
          self
            assert: error messageText equals: defaultDescription;
            assert: ( error additionalDataAt: #type ) equals: 'https://example.com/probs/gone'
        ]
    ]
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

{ #category : 'tests - errors' }
RESTfulAPIClientTest >> testRegisteringAMediaTypeAgainReplacesItsErrorDescription [

  apiClient
    onErrorsTyped: ZnMimeType textPlain do: [ :error :response | error messageText: 'First' ];
    onErrorsTyped: ZnMimeType textPlain do: [ :error :response | error messageText: 'Second' ].
  self configureHttpClientToRespondWith: self notFoundResponse.

  self
    should: [ apiClient get: self location withSuccessfulResponseDo: [ :contents | self fail ] ]
    raise: HTTPClientError notFound
    withMessageText: 'Second'
]

{ #category : 'tests - errors' }
RESTfulAPIClientTest >> testReplacingTheJSONErrorDescription [

  apiClient onErrorsTyped: ZnMimeType applicationJson do: [ :error :response |
      error messageText: ( ( NeoJSONObject fromString: response contents ) at: #error ) ].
  self configureHttpClientToRespondWith:
    ( self responseCoded: 404 containing: '{"error":"Gone"}' typed: ZnMimeType applicationJson ).

  self everyMethodWithItsDefaultErrorDescriptionDo: [ :invocation :defaultDescription |
      self should: invocation raise: HTTPClientError notFound withMessageText: 'Gone' ]
]

{ #category : 'tests - errors' }
RESTfulAPIClientTest >> testServerErrorsAreSignaledAsServerErrors [

  self configureHttpClientToRespondWith:
    ( self responseCoded: 503 containing: 'Service Unavailable' typed: ZnMimeType textHtml ).

  self everyMethodWithItsDefaultErrorDescriptionDo: [ :invocation :defaultDescription |
      self
        should: invocation
        raise: HTTPServerError serviceUnavailable
        withMessageText: defaultDescription
    ]
]

{ #category : 'private' }
RESTfulAPIClientTest >> unauthorizedResponse [

  ^ ZnResponse unauthorized
]

{ #category : 'private' }
RESTfulAPIClientTest >> withJsonFrom: aString do: aBlock [

	aBlock value: ( NeoJSONObject fromString: aString )
]
