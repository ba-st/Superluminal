tests
testApplyOn

	| httpClient command json |

	httpClient := ZnClient new.
	json := '{"last_name":"fox","first_name":"fran"}'.
	command := SetBodyCommand to: (ZnStringEntity json: json).
	command applyOn: httpClient.

	self
		assert: httpClient request contentLength equals: json size;
		assert: httpClient request contentType equals: 'application/json' asMIMEType;
		assert: httpClient request contents equals: json