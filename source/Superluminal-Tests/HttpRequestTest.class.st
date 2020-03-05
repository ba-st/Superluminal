"
A NapTest is a test class for testing the behavior of Nap
"
Class {
	#name : #HttpRequestTest,
	#superclass : #TestCase,
	#category : #'Superluminal-Tests-Core'
}

{ #category : #tests }
HttpRequestTest >> customEntity [

	^ ZnEntity
		with: self encodedFullName
		type: self fullNameVersion1dot0dot0MediaType
]

{ #category : #accessing }
HttpRequestTest >> encodedFullName [

	^ NeoJSONWriter
		toString:
			(Dictionary new
				at: 'first_name' put: 'fran';
				at: 'last_name' put: 'fox';
				yourself)
]

{ #category : #accessing }
HttpRequestTest >> fullNameVersion1dot0dot0MediaType [

	^ 'application/vnd.nap.full_name+json;version=1.0.0' asMIMEType  
]

{ #category : #tests }
HttpRequestTest >> testComposite [

	| httpRequest response |

	httpRequest := HttpRequest
		get: 'http://httpbin.org/anything' asUrl
		configuredUsing: [ :request | 
			(request
				queryString: [ :queryString | 
					queryString
						fieldNamed: 'first_name' pairedTo: 'fran';
						fieldNamed: 'last_name' pairedTo: 'fox' ]) + 
			(request headers setAcceptTo: self fullNameVersion1dot0dot0MediaType) ].

	response := httpRequest applyOn: ZnClient new.

	self assert: response isSuccess.
	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assert: json url equals: 'http://httpbin.org/anything?last_name=fox&first_name=fran';
				assert: json method equals: 'GET';
				assert: json headers Accept equals: 'application/vnd.nap.full_name+json;version=1.0.0' ]
]

{ #category : #tests }
HttpRequestTest >> testGet [

	| httpRequest response |

	httpRequest := HttpRequest 
		get: 'http://httpbin.org/anything' asUrl.

	response := httpRequest applyOn: ZnClient new.
	
	self assert: response isSuccess.
	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assert: json url equals: 'http://httpbin.org/anything';
				assert: json method equals: 'GET' ]
]

{ #category : #tests }
HttpRequestTest >> testGetWithEmptyConfiguration [

	| httpRequest response |

	httpRequest := HttpRequest 
		get: 'http://httpbin.org/anything' asUrl
		configuredUsing: [].

	response := httpRequest applyOn: ZnClient new.
	
	self assert: response isSuccess.
	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assert: json url equals: 'http://httpbin.org/anything';
				assert: json method equals: 'GET' ]
]

{ #category : #tests }
HttpRequestTest >> testPostEncodedAsJson [

	| httpRequest response |

	httpRequest := HttpRequest
		post: 'http://httpbin.org/anything'
		configuredUsing: [ :request | 
			request body
				json:
					( Dictionary new
						at: 'first_name' put: 'fran';
						at: 'last_name' put: 'fox';
						yourself )
			].

	response := httpRequest applyOn: ZnClient new.

	self assert: response isSuccess.
	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assert: json url equals: 'http://httpbin.org/anything';
				assert: json method equals: 'POST';
				assert: json data equals: '{"last_name":"fox","first_name":"fran"}';
				assert: ( json headers at: #'Content-Type' ) equals: 'application/json'
			]
]

{ #category : #tests }
HttpRequestTest >> testPostEncodedDataAndMediaType [

	| httpRequest response |

	httpRequest := HttpRequest
		post: 'http://httpbin.org/anything'
		configuredUsing: [ :request | 
			request body
				contents: self encodedFullName
				encodedAs: self fullNameVersion1dot0dot0MediaType ].

	response := httpRequest applyOn: ZnClient new.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assert: json url equals: 'http://httpbin.org/anything';
				assert: json method equals: 'POST';
				assert: json data equals: '{"last_name":"fox","first_name":"fran"}';
				assert: (json headers at: #'Content-Type')
					equals: 'application/vnd.nap.full_name+json;version=1.0.0' ]
]

{ #category : #tests }
HttpRequestTest >> testPostFormUrlEncoded [

	| httpRequest response |

	httpRequest := HttpRequest
		post: 'http://httpbin.org/anything' asUrl
		configuredUsing: [ :request | 
			request body
				formUrlEncoded: [ :form | 
					form
						fieldNamed: 'first_name' pairedTo: 'fran';
						fieldNamed: 'last_name' pairedTo: 'fox' ] ].

	response := httpRequest applyOn: ZnClient new.

	self assert: response isSuccess.
	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assert: json url equals: 'http://httpbin.org/anything';
				assert: json method equals: 'POST';
				assert: json form asDictionary
					equals:
					{(#first_name -> 'fran').
					('last_name' -> 'fox')} asDictionary;
				assert: (json headers at: #'Content-Type') equals: 'application/x-www-form-urlencoded' ]
]

{ #category : #tests }
HttpRequestTest >> testPostUsingEntity [

	| httpRequest response |

	httpRequest := HttpRequest
		post: 'http://httpbin.org/anything'
		configuredUsing:
			[ :request | request body contents: self customEntity ].

	response := httpRequest applyOn: ZnClient new.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assert: json url equals: 'http://httpbin.org/anything';
				assert: json method equals: 'POST';
				assert: json data
					equals: '{"last_name":"fox","first_name":"fran"}';
				assert: (json headers at: #'Content-Type')
					equals: 'application/vnd.nap.full_name+json;version=1.0.0' ]
]

{ #category : #tests }
HttpRequestTest >> testQueryString [

	| httpRequest response |

	httpRequest := HttpRequest 
		get: 'http://httpbin.org/anything' asUrl
		configuredUsing: [ :request | 
			request
				queryString: [ :queryString | 
					queryString
						fieldNamed: 'first_name' pairedTo: 'fran';
						fieldNamed: 'last_name' pairedTo: 'fox' ] ].

	response := httpRequest applyOn: ZnClient new.
	
	self assert: response isSuccess.
	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assert: json url equals: 'http://httpbin.org/anything?last_name=fox&first_name=fran';
				assert: json method equals: 'GET' ]
]

{ #category : #'tests - support' }
HttpRequestTest >> withJsonFromContentsIn: httpResponse do: aBlock [

	aBlock value: (NeoJSONObject fromString: httpResponse contents)
]
