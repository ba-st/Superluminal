"
A SetAcceptMediaTypeTest is a test class for testing the behavior of SetAcceptMediaType
"
Class {
	#name : #SetAcceptMediaTypeCommandTest,
	#superclass : #TestCase,
	#category : #'Superluminal-Model-Tests-Commands'
}

{ #category : #tests }
SetAcceptMediaTypeCommandTest >> testApplyOn [

	| httpClient command |

	httpClient := ZnClient new.
	command := SetAcceptMediaTypeCommand to: 'application/json' asMediaType.
	command applyOn: httpClient.

	self assert: httpClient request accept equals: 'application/json'
]
