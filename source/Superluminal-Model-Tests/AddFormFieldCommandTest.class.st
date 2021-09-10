"
An AddFormFieldCommandTest is a test class for testing the behavior of AddFormFieldCommand
"
Class {
	#name : #AddFormFieldCommandTest,
	#superclass : #TestCase,
	#category : #'Superluminal-Model-Tests-Commands'
}

{ #category : #tests }
AddFormFieldCommandTest >> testApplyOn [

	| httpClient command |

	httpClient := ZnClient new.
	command := AddFormFieldCommand named: 'name' pairedTo: 'fran'.
	command applyOn: httpClient.

	self
		assert: httpClient request contentType
		equals: 'application/x-www-form-urlencoded' asZnMimeType.
	self assert: (httpClient request entity includesField: 'name')
]
