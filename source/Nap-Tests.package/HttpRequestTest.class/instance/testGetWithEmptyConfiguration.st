tests
testGetWithEmptyConfiguration

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