"
A RESTfulAPIClientTest is a test class for testing the behavior of RESTfulAPIClient
"
Class {
	#name : #RESTfulAPIClientTest,
	#superclass : #TestCase,
	#instVars : [
		'apiClient'
	],
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #private }
RESTfulAPIClientTest >> httpbinAnythingLocation [

	^ self httpbinLocation / 'anything'
]

{ #category : #private }
RESTfulAPIClientTest >> httpbinCacheLocation [

	^ self httpbinLocation / 'cache'
]

{ #category : #private }
RESTfulAPIClientTest >> httpbinLocation [

	^ 'http://localhost' asUrl
]

{ #category : #private }
RESTfulAPIClientTest >> httpbinStatusLocation [

	^ self httpbinLocation / 'status'
]

{ #category : #running }
RESTfulAPIClientTest >> setUp [

	super setUp.
	apiClient := RESTfulAPIClient default
]

{ #category : #running }
RESTfulAPIClientTest >> tearDown [

	apiClient finalize.
	super tearDown
]

{ #category : #tests }
RESTfulAPIClientTest >> testDeleteAcceptingWithSuccessfulResponseDo [

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

{ #category : #tests }
RESTfulAPIClientTest >> testDeleteNotFound [

	self
		should: [ apiClient
				deleteAt: self httpbinStatusLocation / '404'
				accepting: 'application/json;version=1.0.0' asMediaType
				withSuccessfulResponseDo: [ :responseContents | self fail ]
			]
		raise: HTTPClientError notFound
]

{ #category : #tests }
RESTfulAPIClientTest >> testGetAcceptingWithSuccessfulResponseDo [

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

{ #category : #tests }
RESTfulAPIClientTest >> testGetCached [

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

{ #category : #tests }
RESTfulAPIClientTest >> testGetConfiguringRequestUsingWithSuccessfulResponseDo [

	apiClient
		get: self httpbinAnythingLocation
		configuringRequestUsing: [ :request | request queryString: [ :queryString | queryString fieldNamed: #step pairedTo: 20 ] ]
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

{ #category : #tests }
RESTfulAPIClientTest >> testGetNotFound [

	self
		should: [ apiClient
				get: self httpbinStatusLocation / '404'
				withSuccessfulResponseDo: [ :responseContents | self fail ]
			]
		raise: HTTPClientError notFound
]

{ #category : #tests }
RESTfulAPIClientTest >> testGetWithSuccessfulResponseDo [

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

{ #category : #tests }
RESTfulAPIClientTest >> testPatchAtNoContent [

	apiClient
		patch: ( ZnEntity json: '[]' )
		at: self httpbinStatusLocation / '204'
		withSuccessfulResponseDo: [ :responseContents | self assert: responseContents isNil ]
]

{ #category : #tests }
RESTfulAPIClientTest >> testPatchAtNotFound [

	self
		should: [ apiClient
				patch: ( ZnEntity json: '[]' )
				at: self httpbinStatusLocation / '404'
				withSuccessfulResponseDo: [ :response | self fail ]
			]
		raise: HTTPClientError notFound
		withMessageText: 'Cannot complete update'
]

{ #category : #tests }
RESTfulAPIClientTest >> testPatchAtWithSuccessfulResponseDo [

	apiClient
		patch: ( ZnEntity json: '[]' )
		at: self httpbinAnythingLocation
		withSuccessfulResponseDo: [ :responseContents | 
			self
				withJsonFrom: responseContents
				do: [ :json | 
					self
						assert: json json equals: #();
						assertUrl: json url equals: self httpbinAnythingLocation;
						assert: json method equals: 'PATCH';
						assert: ( json headers at: #Accept ) equals: '*/*'
					]
			]
]

{ #category : #tests }
RESTfulAPIClientTest >> testPostBadRequest [

	self
		should: [ apiClient
				post: ( ZnEntity json: '["hi"]' )
				at: self httpbinStatusLocation / '400'
				withSuccessfulResponseDo: [ self fail ]
			]
		raise: HTTPClientError badRequest
		withMessageText: 'Cannot complete the request'
]

{ #category : #tests }
RESTfulAPIClientTest >> testPostWithSuccessfulResponseDo [

	apiClient
		post: ( ZnEntity json: '[]' )
		at: self httpbinAnythingLocation
		withSuccessfulResponseDo: [ :responseContents | 
			self
				withJsonFrom: responseContents
				do: [ :json | 
					self
						assert: json json equals: #();
						assertUrl: json url equals: self httpbinAnythingLocation;
						assert: json method equals: 'POST';
						assert: ( json headers at: #Accept ) equals: '*/*'
					]
			]
]

{ #category : #tests }
RESTfulAPIClientTest >> testPutAt [

	| response |

	response := apiClient put: ( ZnEntity json: '["hi"]' ) at: 'http://localhost/put'.

	self
		withJsonFrom: response contents
		do: [ :json | 
			self
				assert: json json equals: #('hi');
				assertUrl: json url equals: 'http://localhost/put';
				assert: ( json headers at: #Accept ) equals: '*/*';
				assert: ( json headers at: #'Content-Length' ) equals: '6'
			]
]

{ #category : #tests }
RESTfulAPIClientTest >> testPutAtNoContent [

	| response |

	response := apiClient put: ( ZnEntity json: '["hi"]' ) at: self httpbinStatusLocation / '204'.

	self assert: response isNoContent
]

{ #category : #tests }
RESTfulAPIClientTest >> testPutAtNotFound [

	self
		should: [ apiClient put: ( ZnEntity json: '["hi"]' ) at: self httpbinStatusLocation / '404' ]
		raise: HTTPClientError notFound
		withMessageText: 'Cannot complete update'
]

{ #category : #private }
RESTfulAPIClientTest >> withJsonFrom: aString do: aBlock [

	aBlock value: ( NeoJSONObject fromString: aString )
]
