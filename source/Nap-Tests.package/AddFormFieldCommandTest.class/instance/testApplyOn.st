tests
testApplyOn

	| httpClient command |

	httpClient := ZnClient new.
	command := AddFormFieldCommand named: 'name' pairedTo: 'fran'.
	command applyOn: httpClient.

	self
		assert: httpClient request contentType
		equals: 'application/x-www-form-urlencoded' asZnMimeType.
	self assert: (httpClient request entity includesField: 'name')