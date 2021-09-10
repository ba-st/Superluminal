"
An AddQueryStringFieldTest is a test class for testing the behavior of AddQueryStringField
"
Class {
	#name : #AddQueryStringFieldCommandTest,
	#superclass : #TestCase,
	#category : #'Superluminal-Model-Tests-Commands'
}

{ #category : #tests }
AddQueryStringFieldCommandTest >> testApplyOn [

	| httpClient command |

	httpClient := ZnClient new.
	command := AddQueryStringFieldCommand named: 'name' pairedTo: 'fran'.
	command applyOn: httpClient.

	self assert: (httpClient request url queryAt: #name) equals: 'fran'
]
