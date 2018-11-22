tests
testContentAsFormUrlEncoded

	| httpRequest response |

	httpRequest := HttpRequest 
		post: 'http://httpbin.org/anything' asUrl
		configuredUsing: [:request | 
			request body asFormUrlEncoded: [ :form | 
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