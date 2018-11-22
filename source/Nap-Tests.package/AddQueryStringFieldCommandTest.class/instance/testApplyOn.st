tests
testApplyOn

	| httpClient command |

	httpClient := ZnClient new.
	command := AddQueryStringFieldCommand named: 'name' pairedTo: 'fran'.
	command applyOn: httpClient.

	self assert: (httpClient request url queryAt: #name) equals: 'fran'