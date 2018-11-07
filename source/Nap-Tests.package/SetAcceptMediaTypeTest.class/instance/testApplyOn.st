tests
testApplyOn

	| httpClient command |

	httpClient := ZnClient new.
	command := SetAcceptMediaType to: 'application/json' asZnMimeType.
	command applyOn: httpClient.

	self assert: (httpClient request accept) equals: 'application/json'