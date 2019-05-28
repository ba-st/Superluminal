Class {
	#name : #SetContentTypeCommand,
	#superclass : #HttpRequestCommand,
	#instVars : [
		'mediaType'
	],
	#category : #'Superluminal-Model-Commands'
}

{ #category : #'instance creation' }
SetContentTypeCommand class >> to: aMediaType [

	^ self new initializeTo: aMediaType asMediaType 
]

{ #category : #applying }
SetContentTypeCommand >> applyOn: anHttpClient [

	anHttpClient contentType: mediaType
]

{ #category : #initialization }
SetContentTypeCommand >> initializeTo: aMediaType [

	mediaType := aMediaType
]
