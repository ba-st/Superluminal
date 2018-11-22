tests
testApplyOn

	| httpClient command |

	httpClient := ZnClient new.
	command := CompositeHttpRequestCommand
		ofAll:
			(Array
				with: (AddQueryStringFieldCommand named: 'fist_name' pairedTo: 'fran')
				with: (AddQueryStringFieldCommand named: 'last_name' pairedTo: 'fox')).

	command applyOn: httpClient.

	self assert: httpClient request uri equals: '/?last_name=fox&fist_name=fran' asUrl