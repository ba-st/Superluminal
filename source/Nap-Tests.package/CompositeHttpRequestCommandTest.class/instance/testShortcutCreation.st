tests
testShortcutCreation

	| httpClient command |

	httpClient := ZnClient new.
	command := (AddQueryStringFieldCommand named: 'fist_name' pairedTo: 'fran')
		+ (AddQueryStringFieldCommand named: 'last_name' pairedTo: 'fox').

	command applyOn: httpClient.

	self assert: httpClient request uri equals: '/?last_name=fox&fist_name=fran' asUrl