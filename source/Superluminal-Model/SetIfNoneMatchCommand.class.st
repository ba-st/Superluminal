Class {
	#name : 'SetIfNoneMatchCommand',
	#superclass : 'HttpRequestCommand',
	#instVars : [
		'entityTag'
	],
	#category : 'Superluminal-Model-Commands',
	#package : 'Superluminal-Model',
	#tag : 'Commands'
}

{ #category : 'instance creation' }
SetIfNoneMatchCommand class >> to: anEntityTag [ 

	 ^ self new initializeTo: anEntityTag 
]

{ #category : 'applying' }
SetIfNoneMatchCommand >> applyOn: httpClient [

	httpClient setIfNoneMatchTo: entityTag
]

{ #category : 'initialization' }
SetIfNoneMatchCommand >> initializeTo: anEntityTag [

	entityTag := anEntityTag
]
