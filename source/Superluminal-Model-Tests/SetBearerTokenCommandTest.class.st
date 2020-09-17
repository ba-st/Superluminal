Class {
	#name : #SetBearerTokenCommandTest,
	#superclass : #TestCase,
	#category : #'Superluminal-Model-Tests-Commands'
}

{ #category : #tests }
SetBearerTokenCommandTest >> testApplyOn [

	| httpClient command |

	httpClient := ZnClient new.
	command := SetBearerTokenCommand to: 'token'.
	command applyOn: httpClient.

	self assert: ( httpClient request headers at: #Authorization ) equals: 'Bearer ''token'''
]
