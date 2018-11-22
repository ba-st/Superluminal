tests
testQueryString

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