Class {
	#name : #SetContentTypeCommand,
	#superclass : #HttpRequestCommand,
	#instVars : [
		'mediaType'
	],
	#category : #'Superluminal-Model-Commands'
}

{ #category : #'Instance Creation' }
SetContentTypeCommand class >> to: aMediaType [

	^ self new initializeTo: aMediaType asMediaType 
]

{ #category : #initialization }
SetContentTypeCommand >> applyOn: anHttpClient [

	anHttpClient contentType: mediaType
]

{ #category : #initialization }
SetContentTypeCommand >> initializeTo: aMediaType [

	mediaType := aMediaType
]
