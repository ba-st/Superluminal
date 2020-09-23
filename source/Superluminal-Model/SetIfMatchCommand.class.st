Class {
	#name : #SetIfMatchCommand,
	#superclass : #HttpRequestCommand,
	#instVars : [
		'entityTag'
	],
	#category : #'Superluminal-Model-Commands'
}

{ #category : #'instance creation' }
SetIfMatchCommand class >> to: anEntityTag [ 

	 ^ self new initializeTo: anEntityTag 
]

{ #category : #applying }
SetIfMatchCommand >> applyOn: httpClient [

	httpClient setIfMatchTo: entityTag
]

{ #category : #initialization }
SetIfMatchCommand >> initializeTo: anEntityTag [

	entityTag := anEntityTag
]
