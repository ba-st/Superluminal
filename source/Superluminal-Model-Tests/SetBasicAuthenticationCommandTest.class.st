Class {
	#name : #SetBasicAuthenticationCommandTest,
	#superclass : #TestCase,
	#category : #'Superluminal-Model-Tests-Commands'
}

{ #category : #tests }
SetBasicAuthenticationCommandTest >> testApplyOn [

	| httpClient command |

	httpClient := ZnClient new.
	command := SetBasicAuthenticationCommand with: 'user' password: 'password'.
	command applyOn: httpClient.

	self assert: ( httpClient request headers at: #Authorization ) equals: 'Basic dXNlcjpwYXNzd29yZA=='
]
