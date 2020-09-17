Class {
	#name : #SetAcceptMediaTypeCommand,
	#superclass : #HttpRequestCommand,
	#instVars : [
		'mediaType'
	],
	#category : #'Superluminal-Model-Commands'
}

{ #category : #'instance creation' }
SetAcceptMediaTypeCommand class >> to: aMediaType [ 

	 ^ self new initializeTo: aMediaType 
]

{ #category : #applying }
SetAcceptMediaTypeCommand >> applyOn: httpClient [ 

	httpClient accept: mediaType 
]

{ #category : #initialization }
SetAcceptMediaTypeCommand >> initializeTo: aMediaType [ 

	mediaType := aMediaType 
]
