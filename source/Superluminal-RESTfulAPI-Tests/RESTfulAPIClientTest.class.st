"
A RESTfulAPIClientTest is a test class for testing the behavior of RESTfulAPIClient
"
Class {
	#name : #RESTfulAPIClientTest,
	#superclass : #TestCase,
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #private }
RESTfulAPIClientTest >> httpBinAnythingLocation [

	^ 'http://httpbin.org/anything' asUrl
]

{ #category : #private }
RESTfulAPIClientTest >> httpBinCacheLocation [

	^ 'http://httpbin.org/cache' asUrl
]

{ #category : #tests }
RESTfulAPIClientTest >> testDeleteAcceptingWithSuccessfulResponseDo [

	| apiClient |

	apiClient := RESTfulAPIClient default.

	apiClient
		deleteAt: self httpBinAnythingLocation
		accepting: 'application/json;version=1.0.0' asMediaType
		withSuccessfulResponseDo: [ :responseContents | 
			self
				withJsonFrom: responseContents
				do: [ :json | 
					self
						assert: json data isEmpty;
						assertUrl: json url equals: self httpBinAnythingLocation;
						assert: json method equals: 'DELETE';
						assert: ( json headers at: #Accept ) equals: 'application/json;version=1.0.0'
					]
			]
]

{ #category : #tests }
RESTfulAPIClientTest >> testGetAcceptingWithSuccessfulResponseDo [

	| apiClient |

	apiClient := RESTfulAPIClient default.

	apiClient
		get: self httpBinAnythingLocation
		accepting: 'application/json;version=1.0.0' asMediaType
		withSuccessfulResponseDo: [ :responseContents | 
			self
				withJsonFrom: responseContents
				do: [ :json | 
					self
						assert: json data isEmpty;
						assertUrl: json url equals: self httpBinAnythingLocation;
						assert: json method equals: 'GET';
						assert: ( json headers at: #Accept ) equals: 'application/json;version=1.0.0'
					]
			]
]

{ #category : #tests }
RESTfulAPIClientTest >> testGetCached [

	| apiClient |

	apiClient := RESTfulAPIClient default.

	apiClient
		get: self httpBinCacheLocation
		withSuccessfulResponseDo: [ :responseContents | 
			self
				withJsonFrom: responseContents
				do: [ :json | self assertUrl: json url equals: self httpBinCacheLocation ]
			].

	apiClient
		get: self httpBinCacheLocation
		withSuccessfulResponseDo: [ :responseContents | 
			self
				withJsonFrom: responseContents
				do: [ :json | 
					self
						assertUrl: json url equals: self httpBinCacheLocation;
						assert: ( json headers at: #Accept ) equals: '*/*'
					]
			]
]

{ #category : #tests }
RESTfulAPIClientTest >> testGetConfiguringRequestUsingWithSuccessfulResponseDo [

	| apiClient |

	apiClient := RESTfulAPIClient default.

	apiClient
		get: self httpBinAnythingLocation
		configuringRequestUsing: [ :request | request queryString: [ :queryString | queryString fieldNamed: #step pairedTo: 20 ] ]
		withSuccessfulResponseDo: [ :responseContents | 
			self
				withJsonFrom: responseContents
				do: [ :json | 
					self
						assert: json data isEmpty;
						assertUrl: json url equals: ( self httpBinAnythingLocation queryAt: 'step' put: 20 );
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
		get: self httpBinAnythingLocation
		withSuccessfulResponseDo: [ :responseContents | 
			self
				withJsonFrom: responseContents
				do: [ :json | 
					self
						assert: json data isEmpty;
						assertUrl: json url equals: self httpBinAnythingLocation;
						assert: json method equals: 'GET';
						assert: ( json headers at: #Accept ) equals: '*/*'
					]
			]
]

{ #category : #private }
RESTfulAPIClientTest >> withJsonFrom: aString do: aBlock [

	aBlock value: ( NeoJSONObject fromString: aString )
]
