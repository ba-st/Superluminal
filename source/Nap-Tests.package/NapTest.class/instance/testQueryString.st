tests
testQueryString

	| nap response |

	nap := Nap using: ZnClient.

	response := nap
		get: 'http://httpbin.org/anything'
		applying: [ :request | 
			request
				queryString: [ :query | 
					query
						fieldNamed: 'first_name' pairedTo: 'fran';
						fieldNamed: 'last_name' pairedTo: 'fox' ] ].

	self assert: response isSuccess.
	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assert: json url equals: 'http://httpbin.org/anything?last_name=fox&first_name=fran';
				assert: json method equals: 'GET' ]