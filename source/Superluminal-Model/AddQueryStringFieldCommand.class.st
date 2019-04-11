Class {
	#name : #AddQueryStringFieldCommand,
	#superclass : #HttpRequestCommand,
	#instVars : [
		'name',
		'value'
	],
	#category : #'Superluminal-Model-Commands'
}

{ #category : #'instance creation' }
AddQueryStringFieldCommand class >> named: aName pairedTo: aValue [

	^ self new initializeNamed: aName pairedTo: aValue
]

{ #category : #applying }
AddQueryStringFieldCommand >> applyOn: anHttpClient [

	anHttpClient queryAt: name put: value
]

{ #category : #initialization }
AddQueryStringFieldCommand >> initializeNamed: aName pairedTo: aValue [

	name := aName.
	value := aValue
]
