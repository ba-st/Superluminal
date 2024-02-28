"
A RESTfulAPIClientTest is a test class for testing the behavior of RESTfulAPIClient
"
Class {
	#name : 'RESTfulAPIClientIntegrationTest',
	#superclass : 'SuperluminalTest',
	#instVars : [
		'apiClient'
	],
	#category : 'Superluminal-RESTfulAPI-Tests',
	#package : 'Superluminal-RESTfulAPI-Tests'
}

{ #category : 'private' }
RESTfulAPIClientIntegrationTest >> httpbinAnythingLocation [

	^ self httpbinLocation / 'anything'
]

{ #category : 'private' }
RESTfulAPIClientIntegrationTest >> httpbinCacheLocation [

	^ self httpbinLocation / 'cache'
]

{ #category : 'private' }
RESTfulAPIClientIntegrationTest >> httpbinLocation [

	^ ('http://<1s>' expandMacrosWith: self httpbinHostname)
		  asAbsoluteUrl
]

{ #category : 'private' }
RESTfulAPIClientIntegrationTest >> httpbinStatusLocation [

	^ self httpbinLocation / 'status'
]

{ #category : 'running' }
RESTfulAPIClientIntegrationTest >> setUp [

	super setUp.
	apiClient := RESTfulAPIClient cachingOnLocalMemory
]

{ #category : 'running' }
RESTfulAPIClientIntegrationTest >> tearDown [

	apiClient finalize.
	super tearDown
]

{ #category : 'tests' }
RESTfulAPIClientIntegrationTest >> testDeleteAcceptingWithSuccessfulResponseDo [

	apiClient
		deleteAt: self httpbinAnythingLocation
		accepting: 'application/json;version=1.0.0' asMediaType
		withSuccessfulResponseDo: [ :responseContents | 
			self
				withJsonFrom: responseContents
				do: [ :json | 
					self
						assert: json data isEmpty;
						assertUrl: json url equals: self httpbinAnythingLocation;
						assert: json method equals: 'DELETE';
						assert: ( json headers at: #Accept ) equals: 'application/json;version=1.0.0'
					]
			]
]

{ #category : 'tests' }
RESTfulAPIClientIntegrationTest >> testDeleteNotFound [

	self
		should: [ apiClient
				deleteAt: self httpbinStatusLocation / '404'
				accepting: 'application/json;version=1.0.0' asMediaType
				withSuccessfulResponseDo: [ :responseContents | self fail ]
			]
		raise: HTTPClientError notFound
]

{ #category : 'tests' }
RESTfulAPIClientIntegrationTest >> testDeletePreconditionFailed [

	self
		should: [ apiClient deleteAt: self httpbinStatusLocation / '412' ]
		raise: HTTPClientError preconditionFailed
]

{ #category : 'tests' }
RESTfulAPIClientIntegrationTest >> testGetAcceptingWithSuccessfulResponseDo [

	apiClient
		get: self httpbinAnythingLocation
		accepting: 'application/json;version=1.0.0' asMediaType
		withSuccessfulResponseDo: [ :responseContents | 
			self
				withJsonFrom: responseContents
				do: [ :json | 
					self
						assert: json data isEmpty;
						assertUrl: json url equals: self httpbinAnythingLocation;
						assert: json method equals: 'GET';
						assert: ( json headers at: #Accept ) equals: 'application/json;version=1.0.0'
					]
			]
]

{ #category : 'tests' }
RESTfulAPIClientIntegrationTest >> testGetAtConfiguredByWithSuccessfulResponseDo [

	apiClient
		getAt: self httpbinAnythingLocation
		configuredBy: [ :request | request queryString: [ :queryString | queryString fieldNamed: #step pairedTo: 20 ] ]
		withSuccessfulResponseDo: [ :responseContents | 
			self
				withJsonFrom: responseContents
				do: [ :json | 
					self
						assert: json data isEmpty;
						assertUrl: json url equals: ( self httpbinAnythingLocation queryAt: 'step' put: 20 );
						assert: json method equals: 'GET';
						assert: ( json headers at: #Accept ) equals: '*/*'
					]
			]
]

{ #category : 'tests' }
RESTfulAPIClientIntegrationTest >> testGetCached [

	apiClient
		get: self httpbinCacheLocation
		withSuccessfulResponseDo: [ :responseContents | 
			self
				withJsonFrom: responseContents
				do: [ :json | self assertUrl: json url equals: self httpbinCacheLocation ]
			].

	apiClient
		get: self httpbinCacheLocation
		withSuccessfulResponseDo: [ :responseContents | 
			self
				withJsonFrom: responseContents
				do: [ :json | 
					self
						assertUrl: json url equals: self httpbinCacheLocation;
						assert: ( json headers at: #Accept ) equals: '*/*'
					]
			]
]

{ #category : 'tests' }
RESTfulAPIClientIntegrationTest >> testGetNotFound [

	self
		should: [ apiClient
				get: self httpbinStatusLocation / '404'
				withSuccessfulResponseDo: [ :responseContents | self fail ]
			]
		raise: HTTPClientError notFound
]

{ #category : 'tests' }
RESTfulAPIClientIntegrationTest >> testGetWithSuccessfulResponseDo [

	apiClient
		get: self httpbinAnythingLocation
		withSuccessfulResponseDo: [ :responseContents | 
			self
				withJsonFrom: responseContents
				do: [ :json | 
					self
						assert: json data isEmpty;
						assertUrl: json url equals: self httpbinAnythingLocation;
						assert: json method equals: 'GET';
						assert: ( json headers at: #Accept ) equals: '*/*'
					]
			]
]

{ #category : 'tests' }
RESTfulAPIClientIntegrationTest >> testPatchAtNoContent [

	apiClient
		patch: ( ZnEntity json: '[]' )
		at: self httpbinStatusLocation / '204'
		withSuccessfulResponseDo: [ :responseContents | self assert: responseContents isNil ]
]

{ #category : 'tests' }
RESTfulAPIClientIntegrationTest >> testPatchAtNotFound [

	self
		should: [ apiClient
				patch: ( ZnEntity json: '[]' )
				at: self httpbinStatusLocation / '404'
				withSuccessfulResponseDo: [ :response | self fail ]
			]
		raise: HTTPClientError notFound
		withMessageText: 'Cannot complete update'
]

{ #category : 'tests' }
RESTfulAPIClientIntegrationTest >> testPatchAtWithSuccessfulResponseDo [

	apiClient
		patch: ( ZnEntity json: '[]' )
		at: self httpbinAnythingLocation
		withSuccessfulResponseDo: [ :responseContents | 
			self
				withJsonFrom: responseContents
				do: [ :json | 
					self
						assert: json json hasTheSameElementsInTheSameOrderThat: #();
						assertUrl: json url equals: self httpbinAnythingLocation;
						assert: json method equals: 'PATCH';
						assert: ( json headers at: #Accept ) equals: '*/*'
					]
			]
]

{ #category : 'tests' }
RESTfulAPIClientIntegrationTest >> testPostBadRequest [

	self
		should: [ apiClient
				post: ( ZnEntity json: '["hi"]' )
				at: self httpbinStatusLocation / '400'
				withSuccessfulResponseDo: [ self fail ]
			]
		raise: HTTPClientError badRequest
		withMessageText: 'Cannot complete the request'
]

{ #category : 'tests' }
RESTfulAPIClientIntegrationTest >> testPostWithSuccessfulResponseDo [

	apiClient
		post: ( ZnEntity json: '[]' )
		at: self httpbinAnythingLocation
		withSuccessfulResponseDo: [ :responseContents | 
			self
				withJsonFrom: responseContents
				do: [ :json | 
					self
						assert: json json hasTheSameElementsInTheSameOrderThat: #();
						assertUrl: json url equals: self httpbinAnythingLocation;
						assert: json method equals: 'POST';
						assert: ( json headers at: #Accept ) equals: '*/*'
					]
			]
]

{ #category : 'tests' }
RESTfulAPIClientIntegrationTest >> testPutAt [

	| response |

	response := apiClient put: ( ZnEntity json: '["hi"]' ) at: self httpbinLocation / 'put'.

	self withJsonFrom: response contents do: [ :json | 
		self
			assert: json json hasTheSameElementsInTheSameOrderThat: #( 'hi' );
			assertUrl: json url equals: self httpbinLocation / 'put';
			assert: ( json headers at: #Accept ) equals: '*/*';
			assert: ( json headers at: #'Content-Length' ) equals: '6'
		]
]

{ #category : 'tests' }
RESTfulAPIClientIntegrationTest >> testPutAtNoContent [

	| response |

	response := apiClient put: ( ZnEntity json: '["hi"]' ) at: self httpbinStatusLocation / '204'.

	self assert: response isNoContent
]

{ #category : 'tests' }
RESTfulAPIClientIntegrationTest >> testPutAtNotFound [

	self
		should: [ apiClient put: ( ZnEntity json: '["hi"]' ) at: self httpbinStatusLocation / '404' ]
		raise: HTTPClientError notFound
		withMessageText: 'Cannot complete update'
]

{ #category : 'private' }
RESTfulAPIClientIntegrationTest >> withJsonFrom: aString do: aBlock [

	aBlock value: ( NeoJSONObject fromString: aString )
]
