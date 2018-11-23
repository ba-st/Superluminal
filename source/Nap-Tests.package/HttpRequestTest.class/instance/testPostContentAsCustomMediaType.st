tests
testPostContentAsCustomMediaType

	| httpRequest response |

	httpRequest := HttpRequest
		post: 'http://httpbin.org/anything'
		configuredUsing: [ :request | 
			request body
				to: self encodedFullName
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