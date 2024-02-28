Class {
	#name : 'AddMultiPartCommand',
	#superclass : 'HttpRequestCommand',
	#instVars : [
		'mimePart'
	],
	#category : 'Superluminal-Model-Commands',
	#package : 'Superluminal-Model',
	#tag : 'Commands'
}

{ #category : 'private - instance creation' }
AddMultiPartCommand class >> adding: aMimePart [

	^ self new initializeAdding: aMimePart
]

{ #category : 'instance creation' }
AddMultiPartCommand class >> named: aName attaching: aFileReference [

	^ self adding: ( ZnMimePart fieldName: aName fileNamed: aFileReference fullName )
]

{ #category : 'instance creation' }
AddMultiPartCommand class >> named: aName pairedTo: aValue [

	^ self adding: ( ZnMimePart fieldName: aName value: aValue )
]

{ #category : 'applying' }
AddMultiPartCommand >> applyOn: httpClient [

	httpClient addPart: mimePart
]

{ #category : 'initialization' }
AddMultiPartCommand >> initializeAdding: aMimePart [

	mimePart := aMimePart
]
