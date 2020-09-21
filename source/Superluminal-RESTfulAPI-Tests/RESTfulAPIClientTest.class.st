"
A RESTfulAPIClientTest is a test class for testing the behavior of RESTfulAPIClient
"
Class {
	#name : #RESTfulAPIClientTest,
	#superclass : #TestCase,
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #tests }
RESTfulAPIClientTest >> testDeleteAcceptingWithSuccessfulResponseDo [

	| apiClient |

	apiClient := RESTfulAPIClient default.

	apiClient
		deleteAt: 'http://httpbin.mercap.net/anything'
		accepting: 'application/json;version=1.0.0' asMediaType
		withSuccessfulResponseDo: [:responseContents |
			self
				withJsonFrom: responseContents
				do: [:json |
					self
						assert: json data isEmpty;
						assert: json url equals: 'http://httpbin.mercap.net/anything';
						assert: json method equals: 'DELETE';
						assert: (json headers at: #Accept) equals: 'application/json;version=1.0.0']]
]

{ #category : #tests }
RESTfulAPIClientTest >> testGetAcceptingWithSuccessfulResponseDo [

	| apiClient |

	apiClient := RESTfulAPIClient default.

	apiClient
		get: 'http://httpbin.mercap.net/anything'
		accepting: 'application/json;version=1.0.0' asMediaType
		withSuccessfulResponseDo: [:responseContents |
			self
				withJsonFrom: responseContents
				do: [:json |
					self
						assert: json data isEmpty;
						assert: json url equals: 'http://httpbin.mercap.net/anything';
						assert: json method equals: 'GET';
						assert: (json headers at: #Accept) equals: 'application/json;version=1.0.0']]
]

{ #category : #tests }
RESTfulAPIClientTest >> testGetCached [

	| apiClient |

	apiClient := RESTfulAPIClient default.

	apiClient
		get: 'http://httpbin.mercap.net/cache'
		withSuccessfulResponseDo: [ :responseContents | 
			self
				withJsonFrom: responseContents
				do: [ :json | self assert: json url equals: 'http://httpbin.mercap.net/cache' ]
			].

	apiClient
		get: 'http://httpbin.mercap.net/cache'
		withSuccessfulResponseDo: [ :responseContents | 
			self
				withJsonFrom: responseContents
				do: [ :json | 
					self
						assert: json url equals: 'http://httpbin.mercap.net/cache';
						assert: ( json headers at: #Accept ) equals: '*/*'
					]
			]
]

{ #category : #tests }
RESTfulAPIClientTest >> testGetConfiguringRequestUsingWithSuccessfulResponseDo [

	| apiClient |

	apiClient := RESTfulAPIClient default.

	apiClient
		get: 'http://httpbin.mercap.net/anything'
		configuringRequestUsing: [ :request | request queryString: [ :queryString | queryString fieldNamed: #step pairedTo: 20 ] ]
		withSuccessfulResponseDo: [ :responseContents | 
			self
				withJsonFrom: responseContents
				do: [ :json | 
					self
						assert: json data isEmpty;
						assert: json url equals: 'http://httpbin.mercap.net/anything?step=20';
						assert: json method equals: 'GET';
						assert: ( json headers at: #Accept ) equals: '*/*'
					]
			]
]

{ #category : #tests }
RESTfulAPIClientTest >> testGetWithSuccessfulResponseDo [

	| apiClient |

	apiClient := RESTfulAPIClient default.

	apiClient
		get: 'http://httpbin.mercap.net/anything'
		withSuccessfulResponseDo: [ :responseContents | 
			self
				withJsonFrom: responseContents
				do: [ :json | 
					self
						assert: json data isEmpty;
						assert: json url equals: 'http://httpbin.mercap.net/anything';
						assert: json method equals: 'GET';
						assert: ( json headers at: #Accept ) equals: '*/*'
					]
			]
]

{ #category : #private }
RESTfulAPIClientTest >> withJsonFrom: aString do: aBlock [

	aBlock value: ( NeoJSONObject fromString: aString )
]
