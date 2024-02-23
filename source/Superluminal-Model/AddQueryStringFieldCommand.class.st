Class {
	#name : 'AddQueryStringFieldCommand',
	#superclass : 'HttpRequestCommand',
	#instVars : [
		'name',
		'value'
	],
	#category : 'Superluminal-Model-Commands',
	#package : 'Superluminal-Model',
	#tag : 'Commands'
}

{ #category : 'instance creation' }
AddQueryStringFieldCommand class >> named: aName pairedTo: aValue [

	^ self new initializeNamed: aName pairedTo: aValue
]

{ #category : 'applying' }
AddQueryStringFieldCommand >> applyOn: httpClient [

	httpClient queryAt: name put: value
]

{ #category : 'initialization' }
AddQueryStringFieldCommand >> initializeNamed: aName pairedTo: aValue [

	name := aName.
	value := aValue
]
