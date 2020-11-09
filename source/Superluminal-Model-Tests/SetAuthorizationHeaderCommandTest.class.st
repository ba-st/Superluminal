Class {
	#name : #SetAuthorizationHeaderCommandTest,
	#superclass : #TestCase,
	#category : #'Superluminal-Model-Tests-Commands'
}

{ #category : #tests }
SetAuthorizationHeaderCommandTest >> testApplyOn [

	| httpClient command |

	httpClient := ZnClient new.
	command := SetAuthorizationHeaderCommand toBearerToken:  'token'.
	command applyOn: httpClient.

	self assert: ( httpClient request headers at: #Authorization ) equals: 'Bearer ''token'''
]
