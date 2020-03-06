Class {
	#name : #HttpRequestHeadersBuilder,
	#superclass : #Object,
	#category : #'Superluminal-Model-Builders'
}

{ #category : #supplying }
HttpRequestHeadersBuilder >> setAcceptTo: aMediaType [
	
	^ SetAcceptMediaTypeCommand to: aMediaType 
]
