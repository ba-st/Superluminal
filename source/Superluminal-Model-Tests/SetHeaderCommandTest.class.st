Class {
	#name : 'SetHeaderCommandTest',
	#superclass : 'TestCase',
	#category : 'Superluminal-Model-Tests-Commands',
	#package : 'Superluminal-Model-Tests',
	#tag : 'Commands'
}

{ #category : 'tests' }
SetHeaderCommandTest >> testApplyOn [

	| httpClient command |

	httpClient := ZnClient new.
	command := SetHeaderCommand settingAuthorizationToBearerToken:  'token'.
	command applyOn: httpClient.

	self assert: ( httpClient request headers at: #Authorization ) equals: 'Bearer token'
]

{ #category : 'tests' }
SetHeaderCommandTest >> testCannotUseAnEmptyValue [

	self
		should: [ SetHeaderCommand settingAuthorizationTo: '' ]
		raise: InstanceCreationFailed
		withMessageText: 'An Authorization header cannot include empty directives.'
]
