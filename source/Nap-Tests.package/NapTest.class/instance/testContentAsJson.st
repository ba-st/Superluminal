tests
testContentAsJson

	| nap response |

	nap := Nap using: ZnClient.

	response := nap
		post: 'http://httpbin.org/anything'
		applying: [ :request | 
			request
				json:
					(Dictionary new
						at: 'first_name' put: 'fran';
						at: 'last_name' put: 'fox';
						yourself) ].

	self assert: response isSuccess.
	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assert: json url equals: 'http://httpbin.org/anything';
				assert: json method equals: 'POST';
				assert: json data equals: '{"last_name":"fox","first_name":"fran"}' ]