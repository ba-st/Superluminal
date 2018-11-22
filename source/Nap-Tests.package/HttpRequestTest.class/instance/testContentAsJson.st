tests
testContentAsJson

	| httpRequest response |

	httpRequest := HttpRequest 
		post: 'http://httpbin.org/anything'
		configuredUsing: [ :request | 
			request body asJson:
					(Dictionary new
						at: 'first_name' put: 'fran';
						at: 'last_name' put: 'fox';
						yourself) ].

	response := httpRequest applyOn: ZnClient new.

	self assert: response isSuccess.
	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assert: json url equals: 'http://httpbin.org/anything';
				assert: json method equals: 'POST';
				assert: json data equals: '{"last_name":"fox","first_name":"fran"}' ]