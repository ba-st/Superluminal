Class {
	#name : #SetBodyCommand,
	#superclass : #HttpRequestCommand,
	#instVars : [
		'entity'
	],
	#category : #'Superluminal-Model-Commands'
}

{ #category : #'instance creation' }
SetBodyCommand class >> to: anEntity [ 

	^ self new initializeTo: anEntity 
]

{ #category : #applying }
SetBodyCommand >> applyOn: httpClient [

	httpClient entity: entity
]

{ #category : #initialization }
SetBodyCommand >> initializeTo: anEntity [ 
	
	entity := anEntity 
]
