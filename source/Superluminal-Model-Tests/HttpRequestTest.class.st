"
A NapTest is a test class for testing the behavior of Nap
"
Class {
	#name : #HttpRequestTest,
	#superclass : #TestCase,
	#category : #'Superluminal-Model-Tests-Core'
}

{ #category : #private }
HttpRequestTest >> assertJson: json at: attribute equals: anObject [

	self assert: ( json at: attribute ) equals: anObject
]

{ #category : #private }
HttpRequestTest >> customEntity [

	^ ZnEntity
		with: self encodedFullName
		type: self fullNameVersion1dot0dot0MediaType
]

{ #category : #private }
HttpRequestTest >> encodedFullName [

	^ NeoJSONWriter
		toString:
			(Dictionary new
				at: 'first_name' put: 'fran';
				at: 'last_name' put: 'fox';
				yourself)
]

{ #category : #private }
HttpRequestTest >> fullNameVersion1dot0dot0MediaType [

	^ 'application/vnd.nap.full_name+json;version=1.0.0' asMediaType
]

{ #category : #private }
HttpRequestTest >> httpbinLocation [

	^ 'http://localhost/anything'
]

{ #category : #private }
HttpRequestTest >> newHttpClient [

	^ ZnClient new
]

{ #category : #tests }
HttpRequestTest >> testComposite [

	| httpRequest response |

	httpRequest := HttpRequest get: self httpbinLocation configuredUsing: [ :request | 
		               ( request queryString: [ :queryString | 
			                 queryString
				                 fieldNamed: 'first_name' pairedTo: 'fran';
				                 fieldNamed: 'last_name' pairedTo: 'fox'
			                 ] ) + ( request headers setAcceptTo: self fullNameVersion1dot0dot0MediaType )
		               ].

	response := httpRequest applyOn: self newHttpClient.

	self
		assert: response isSuccess;
		withJsonFromContentsIn: response do: [ :json | 
			self
				assertUrl: json url equals: self httpbinLocation , '?last_name=fox&first_name=fran';
				assert: json method equals: 'GET';
				assertJson: json headers at: #Accept equals: 'application/vnd.nap.full_name+json;version=1.0.0'
			]
]

{ #category : #tests }
HttpRequestTest >> testDeleteContentAsCustomMediaType [

	| httpRequest response |

	httpRequest := HttpRequest delete: self httpbinLocation configuredUsing: [ :request | 
		               request body contents: self encodedFullName
			               encodedAs: self fullNameVersion1dot0dot0MediaType ].

	response := httpRequest applyOn: self newHttpClient.

	self
		assert: response isSuccess;
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json url equals: self httpbinLocation;
				assert: json method equals: 'DELETE';
				withJsonFrom: json data do: [ :data | 
					self
						assertJson: data at: #first_name equals: 'fran';
						assertJson: data at: #last_name equals: 'fox'
					];
				assertJson: json headers
				at: #'Content-Type'
				equals: 'application/vnd.nap.full_name+json;version=1.0.0'
			]
]

{ #category : #tests }
HttpRequestTest >> testDeleteWithEmptyConfiguration [

	| httpRequest response |

	httpRequest := HttpRequest delete: self httpbinLocation configuredUsing: [  ].

	response := httpRequest applyOn: self newHttpClient.

	self
		assert: response isSuccess;
		withJsonFromContentsIn: response
			do: [ :json | 
			self
				assert: json url equals: self httpbinLocation;
				assert: json method equals: 'DELETE'
			]
]

{ #category : #tests }
HttpRequestTest >> testGet [

	| httpRequest response |

	httpRequest := HttpRequest get: self httpbinLocation.

	response := httpRequest applyOn: self newHttpClient.

	self
		assert: response isSuccess;
		withJsonFromContentsIn: response
			do: [ :json | 
			self
				assert: json url equals: self httpbinLocation;
				assert: json method equals: 'GET'
			]
]

{ #category : #tests }
HttpRequestTest >> testGetWithAuthorization [

	| httpRequest response |

	httpRequest := HttpRequest get: self httpbinLocation
		               configuredUsing: [ :request | 
		               request headers setAuthorizationTo: 'Basic YWxhZGRpbjpvcGVuc2VzYW1l' ].

	response := httpRequest applyOn: self newHttpClient.

	self
		assert: response isSuccess;
		withJsonFromContentsIn: response do: [ :json | 
			self
				assertUrl: json url equals: self httpbinLocation;
				assert: json method equals: 'GET';
				assertJson: json headers at: #Authorization equals: 'Basic YWxhZGRpbjpvcGVuc2VzYW1l'
			]
]

{ #category : #tests }
HttpRequestTest >> testGetWithCustomHeader [

	| httpRequest response |

	httpRequest := HttpRequest get: self httpbinLocation
		               configuredUsing: [ :request | request headers set: #Authorization to: 'Yes' ].

	response := httpRequest applyOn: self newHttpClient.

	self
		assert: response isSuccess;
		withJsonFromContentsIn: response do: [ :json | 
			self
				assertUrl: json url equals: self httpbinLocation;
				assert: json method equals: 'GET';
				assertJson: json headers at: #Authorization equals: 'Yes'
			]
]

{ #category : #tests }
HttpRequestTest >> testGetWithEmptyConfiguration [

	| httpRequest response |

	httpRequest := HttpRequest get: self httpbinLocation asUrl configuredUsing: [  ].

	response := httpRequest applyOn: self newHttpClient.

	self
		assert: response isSuccess;
		withJsonFromContentsIn: response
			do: [ :json | 
			self
				assertUrl: json url equals: self httpbinLocation;
				assert: json method equals: 'GET'
			]
]

{ #category : #tests }
HttpRequestTest >> testGetWithToken [

	| httpRequest response |

	httpRequest := HttpRequest
		get: self httpbinLocation
		configuredUsing: [ :request | request headers setBearerTokenTo: 'xxx' ].

	response := httpRequest applyOn: self newHttpClient.

	self
		assert: response isSuccess;
		withJsonFromContentsIn: response
			do: [ :json | 
			self
				assertUrl: json url equals: self httpbinLocation;
				assert: json method equals: 'GET';
				assertJson: json headers at: #Authorization equals: 'Bearer xxx'
			]
]

{ #category : #tests }
HttpRequestTest >> testPatchContentAsCustomMediaType [

	| httpRequest response |

	httpRequest := HttpRequest patch: self httpbinLocation configuredUsing: [ :request | 
		               request body contents: self encodedFullName
			               encodedAs: self fullNameVersion1dot0dot0MediaType ].

	response := httpRequest applyOn: self newHttpClient.

	self
		assert: response isSuccess;
		withJsonFromContentsIn: response do: [ :json | 
			self
				assertUrl: json url equals: self httpbinLocation;
				assert: json method equals: 'PATCH';
				withJsonFrom: json data do: [ :data | 
					self
						assertJson: data at: #first_name equals: 'fran';
						assertJson: data at: #last_name equals: 'fox'
					];
				assertJson: json headers
				at: #'Content-Type'
				equals: 'application/vnd.nap.full_name+json;version=1.0.0'
			]
]

{ #category : #tests }
HttpRequestTest >> testPatchContentAsFormUrlEncoded [

	| httpRequest response |

	httpRequest := HttpRequest patch: self httpbinLocation configuredUsing: [ :request | 
		               request body formUrlEncoded: [ :form | 
			               form
				               fieldNamed: 'first_name' pairedTo: 'fran';
				               fieldNamed: 'last_name' pairedTo: 'fox'
			               ]
		               ].

	response := httpRequest applyOn: self newHttpClient.

	self
		assert: response isSuccess;
		withJsonFromContentsIn: response do: [ :json | 
			self
				assertUrl: json url equals: self httpbinLocation;
				assert: json method equals: 'PATCH';
				assertJson: json form at: #first_name equals: 'fran';
				assertJson: json form at: #last_name equals: 'fox';
				assertJson: json headers at: #'Content-Type' equals: 'application/x-www-form-urlencoded'
			]
]

{ #category : #tests }
HttpRequestTest >> testPatchContentAsJson [

	| httpRequest response |

	httpRequest := HttpRequest patch: self httpbinLocation configuredUsing: [ :request | 
		               request body json: ( Dictionary new
				                 at: 'first_name' put: 'fran';
				                 at: 'last_name' put: 'fox';
				                 yourself )
		               ].

	response := httpRequest applyOn: self newHttpClient.

	self
		assert: response isSuccess;
		withJsonFromContentsIn: response do: [ :json | 
			self
				assertUrl: json url equals: self httpbinLocation;
				assert: json method equals: 'PATCH';
				withJsonFrom: json data do: [ :data | 
					self
						assertJson: data at: #first_name equals: 'fran';
						assertJson: data at: #last_name equals: 'fox'
					]
			]
]

{ #category : #tests }
HttpRequestTest >> testPatchContentAsMultiPart [

	self withFileNamed: 'testApplyOnWhenAttachingFiles-1.txt'
		containing: '12121212'
		do: [ :filename | 
			self withFileNamed: 'testApplyOnWhenAttachingFiles-2.txt'
				containing: '34343434'
				do: [ :anotherFilename | 
					| httpRequest response |

					httpRequest := HttpRequest patch: self httpbinLocation configuredUsing: [ :request | 
						               request body multiPart: [ :parts | 
							               parts
								               fieldNamed: 'details' pairedTo: 'fran';
								               fieldNamed: 'file' attaching: filename asFileReference;
								               fieldNamed: 'anotherFile' attaching: anotherFilename asFileReference
							               ]
						               ].

					response := httpRequest applyOn: self newHttpClient.

					self
						assert: response isSuccess;
						withJsonFromContentsIn: response do: [ :json | 
							self
								assertUrl: json url equals: self httpbinLocation;
								assert: json method equals: 'PATCH';
								assertJson: json form at: #details equals: 'fran';
								assertJson: json files at: #file equals: '12121212';
								assertJson: json files at: #anotherFile equals: '34343434';
								assert: ( ( json headers at: #'Content-Type' ) beginsWith: 'multipart/form-data' )
							]
					]
			]
]

{ #category : #tests }
HttpRequestTest >> testPostEncodedAsJson [

	| httpRequest response |

	httpRequest := HttpRequest post: self httpbinLocation configuredUsing: [ :request | 
		               request body json: ( Dictionary new
				                 at: 'first_name' put: 'fran';
				                 at: 'last_name' put: 'fox';
				                 yourself )
		               ].

	response := httpRequest applyOn: self newHttpClient.

	self
		assert: response isSuccess;
		withJsonFromContentsIn: response do: [ :json | 
			self
				assertUrl: json url equals: self httpbinLocation;
				assert: json method equals: 'POST';
				withJsonFrom: json data do: [ :data | 
					self
						assertJson: data at: #first_name equals: 'fran';
						assertJson: data at: #last_name equals: 'fox'
					];
				assertJson: json headers at: #'Content-Type' equals: 'application/json'
			]
]

{ #category : #tests }
HttpRequestTest >> testPostEncodedDataAndMediaType [

	| httpRequest response |

	httpRequest := HttpRequest post: self httpbinLocation configuredUsing: [ :request | 
		               request body contents: self encodedFullName
			               encodedAs: self fullNameVersion1dot0dot0MediaType ].

	response := httpRequest applyOn: self newHttpClient.

	self
		assert: response isSuccess;
		withJsonFromContentsIn: response do: [ :json | 
			self
				assertUrl: json url equals: self httpbinLocation;
				assert: json method equals: 'POST';
				withJsonFrom: json data do: [ :data | 
					self
						assertJson: data at: #first_name equals: 'fran';
						assertJson: data at: #last_name equals: 'fox'
					];
				assertJson: json headers
				at: #'Content-Type'
				equals: 'application/vnd.nap.full_name+json;version=1.0.0'
			]
]

{ #category : #tests }
HttpRequestTest >> testPostFormUrlEncoded [

	| httpRequest response |

	httpRequest := HttpRequest post: self httpbinLocation configuredUsing: [ :request | 
		               request body formUrlEncoded: [ :form | 
			               form
				               fieldNamed: 'first_name' pairedTo: 'fran';
				               fieldNamed: 'last_name' pairedTo: 'fox'
			               ]
		               ].

	response := httpRequest applyOn: self newHttpClient.

	self
		assert: response isSuccess;
		withJsonFromContentsIn: response do: [ :json | 
			self
				assertUrl: json url equals: self httpbinLocation;
				assert: json method equals: 'POST';
				assertJson: json form at: #first_name equals: 'fran';
				assertJson: json form at: #last_name equals: 'fox';
				assertJson: json headers at: #'Content-Type' equals: 'application/x-www-form-urlencoded'
			]
]

{ #category : #tests }
HttpRequestTest >> testPostMultiPart [

	self withFileNamed: 'testApplyOnWhenAttachingFiles-1.txt'
		containing: '12121212'
		do: [ :filename | 
			self withFileNamed: 'testApplyOnWhenAttachingFiles-2.txt'
				containing: '34343434'
				do: [ :anotherFilename | 
					| httpRequest response |

					httpRequest := HttpRequest post: self httpbinLocation configuredUsing: [ :request | 
						               request body multiPart: [ :parts | 
							               parts
								               fieldNamed: 'details' pairedTo: 'fran';
								               fieldNamed: 'file' attaching: filename asFileReference;
								               fieldNamed: 'anotherFile' attaching: anotherFilename asFileReference
							               ]
						               ].

					response := httpRequest applyOn: self newHttpClient.

					self
						assert: response isSuccess;
						withJsonFromContentsIn: response do: [ :json | 
							self
								assertUrl: json url equals: self httpbinLocation;
								assert: json method equals: 'POST';
								assertJson: json form at: #details equals: 'fran';
								assertJson: json files at: #file equals: '12121212';
								assertJson: json files at: #anotherFile equals: '34343434';
								assert: ( ( json headers at: #'Content-Type' ) beginsWith: 'multipart/form-data' )
							]
					]
			]
]

{ #category : #tests }
HttpRequestTest >> testPostUsingEntity [

	| httpRequest response |

	httpRequest := HttpRequest post: self httpbinLocation
		               configuredUsing: [ :request | request body contents: self customEntity ].

	response := httpRequest applyOn: self newHttpClient.

	self withJsonFromContentsIn: response do: [ :json | 
		self
			assertUrl: json url equals: self httpbinLocation;
			assert: json method equals: 'POST';
			withJsonFrom: json data do: [ :data | 
				self
					assertJson: data at: #first_name equals: 'fran';
					assertJson: data at: #last_name equals: 'fox'
				];
			assertJson: json headers
			at: #'Content-Type'
			equals: 'application/vnd.nap.full_name+json;version=1.0.0'
		]
]

{ #category : #tests }
HttpRequestTest >> testPutEncodedAsJson [

	| httpRequest response |

	httpRequest := HttpRequest put: self httpbinLocation configuredUsing: [ :request | 
		               request body json: ( Dictionary new
				                 at: 'first_name' put: 'fran';
				                 at: 'last_name' put: 'fox';
				                 yourself )
		               ].

	response := httpRequest applyOn: self newHttpClient.

	self
		assert: response isSuccess;
		withJsonFromContentsIn: response do: [ :json | 
			self
				assertUrl: json url equals: self httpbinLocation;
				assert: json method equals: 'PUT';
				withJsonFrom: json data do: [ :data | 
					self
						assertJson: data at: #first_name equals: 'fran';
						assertJson: data at: #last_name equals: 'fox'
					];
				assertJson: json headers at: #'Content-Type' equals: 'application/json'
			]
]

{ #category : #tests }
HttpRequestTest >> testPutIfMatch [

	| httpRequest response |

	httpRequest := HttpRequest put: self httpbinLocation configuredUsing: [ :request | 
		               ( request body json: 'hello world' )
		               + ( request headers setIfMatchTo: '"12345"' asETag ) ].

	response := httpRequest applyOn: self newHttpClient.

	self
		assert: response isSuccess;
		withJsonFromContentsIn: response do: [ :json | 
			self
				assertUrl: json url equals: self httpbinLocation;
				assert: json method equals: 'PUT';
				withJsonFrom: json data do: [ :data | self assert: data equals: 'hello world' ];
				assertJson: json headers at: #'Content-Type' equals: 'application/json';
				assertJson: json headers at: #'If-Match' equals: '"12345"'
			]
]

{ #category : #tests }
HttpRequestTest >> testPutIfNoneMatch [

	| httpRequest response |

	httpRequest := HttpRequest put: self httpbinLocation configuredUsing: [ :request | 
		               ( request body json: 'hello world' )
		               + ( request headers setIfNoneMatchTo: '"12345"' asETag ) ].

	response := httpRequest applyOn: self newHttpClient.

	self
		assert: response isSuccess;
		withJsonFromContentsIn: response do: [ :json | 
			self
				assertUrl: json url equals: self httpbinLocation;
				assert: json method equals: 'PUT';
				withJsonFrom: json data do: [ :data | self assert: data equals: 'hello world' ];
				assertJson: json headers at: #'Content-Type' equals: 'application/json';
				assertJson: json headers at: #'If-None-Match' equals: '"12345"'
			]
]

{ #category : #tests }
HttpRequestTest >> testQueryString [

	| httpRequest response |

	httpRequest := HttpRequest
		get: self httpbinLocation
		configuredUsing: [ :request | 
			request
				queryString: [ :queryString | 
					queryString
						fieldNamed: 'first_name' pairedTo: 'fran';
						fieldNamed: 'last_name' pairedTo: 'fox'
					]
			].

	response := httpRequest applyOn: self newHttpClient.

	self
		assert: response isSuccess;
		withJsonFromContentsIn: response
			do: [ :json | 
			self
				assertUrl: json url equals: self httpbinLocation , '?last_name=fox&first_name=fran';
				assert: json method equals: 'GET'
			]
]

{ #category : #tests }
HttpRequestTest >> testRequestConfigurationIsClearedWhenReusingClient [

	| response client |

	client := self newHttpClient.
	( HttpRequest
		patch: self httpbinLocation
		configuredUsing: [ :request | request body json: ( Dictionary with: 'first_name' -> 'fran' ) ] )
		applyOn: client.
	response := ( HttpRequest
		get: self httpbinLocation
		configuredUsing:
			[ :request | request queryString: [ :queryString | queryString fieldNamed: 'last_name' pairedTo: 'fox' ] ] )
		applyOn: client.

	self
		assert: response isSuccess;
		withJsonFromContentsIn: response
			do: [ :json | 
			self
				assertUrl: json url equals: self httpbinLocation , '?last_name=fox';
				assert: json method equals: 'GET';
				assert: ( json headers at: #'Content-Type' ) isNil;
				assert: json data isEmpty
			]
]

{ #category : #private }
HttpRequestTest >> withJsonFrom: aString do: aBlock [

	aBlock value: ( NeoJSONObject fromString: aString )
]

{ #category : #private }
HttpRequestTest >> withJsonFromContentsIn: httpResponse do: aBlock [

	self withJsonFrom: httpResponse contents do: aBlock
]
