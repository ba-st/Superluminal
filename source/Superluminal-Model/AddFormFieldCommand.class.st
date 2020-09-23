Class {
	#name : #AddFormFieldCommand,
	#superclass : #HttpRequestCommand,
	#instVars : [
		'name',
		'value'
	],
	#category : #'Superluminal-Model-Commands'
}

{ #category : #'instance creation' }
AddFormFieldCommand class >> named: aName pairedTo: aValue [

	^ self new initializeNamed: aName pairedTo: aValue.
	
]

{ #category : #applying }
AddFormFieldCommand >> applyOn: httpClient [

	httpClient formAt: name add: value
]

{ #category : #initialization }
AddFormFieldCommand >> initializeNamed: aName pairedTo: aValue [

	name := aName.
	value := aValue
]
