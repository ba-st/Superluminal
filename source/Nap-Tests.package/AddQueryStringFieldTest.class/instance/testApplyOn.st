tests
testApplyOn

	| httpClient command |

	httpClient := ZnClient new.
	command := AddQueryStringField named: 'name' pairedTo: 'fran'.
	command applyOn: httpClient.

	self assert: (httpClient request url queryAt: #name) equals: 'fran'