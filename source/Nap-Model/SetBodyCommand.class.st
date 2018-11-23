Class {
	#name : #SetBodyCommand,
	#superclass : #HttpRequestCommand,
	#instVars : [
		'entity'
	],
	#category : #'Nap-Model-Commands'
}

{ #category : #'instance creation' }
SetBodyCommand class >> to: anEntity [ 

	^ self new initializeTo: anEntity 
]

{ #category : #applying }
SetBodyCommand >> applyOn: anHttpClient [

	anHttpClient entity: entity
]

{ #category : #initialization }
SetBodyCommand >> initializeTo: anEntity [ 
	
	entity := anEntity 
]
