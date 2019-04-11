Class {
	#name : #HttpRequestHeadersSupplier,
	#superclass : #Object,
	#category : #'Superluminal-Model-Builders'
}

{ #category : #supplying }
HttpRequestHeadersSupplier >> setAcceptTo: aMediaType [
	
	^ SetAcceptMediaTypeCommand to: aMediaType 
]
