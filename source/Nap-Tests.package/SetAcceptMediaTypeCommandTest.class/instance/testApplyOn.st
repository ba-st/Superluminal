tests
testApplyOn

	| httpClient command |

	httpClient := ZnClient new.
	command := SetAcceptMediaTypeCommand to: 'application/json' asMIMEType.
	command applyOn: httpClient.

	self assert: (httpClient request accept) equals: 'application/json'