Class {
	#name : #SetAcceptMediaTypeCommand,
	#superclass : #HttpRequestCommand,
	#instVars : [
		'mediaType'
	],
	#category : #'Nap-Model-Commands'
}

{ #category : #'instance creation' }
SetAcceptMediaTypeCommand class >> to: aMediaType [ 

	 ^ self new initializeTo: aMediaType 
]

{ #category : #applying }
SetAcceptMediaTypeCommand >> applyOn: anHttpClient [ 

	anHttpClient accept: mediaType 
]

{ #category : #initialization }
SetAcceptMediaTypeCommand >> initializeTo: aMediaType [ 

	mediaType := aMediaType 
]
