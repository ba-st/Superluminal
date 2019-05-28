Class {
	#name : #HttpRequestHeadersSupplier,
	#superclass : #Object,
	#category : #'Superluminal-Model-Builders'
}

{ #category : #supplying }
HttpRequestHeadersSupplier >> setAcceptTo: aMediaType [
	
	^ SetAcceptMediaTypeCommand to: aMediaType 
]

{ #category : #accessing }
HttpRequestHeadersSupplier >> setContentTypeTo: aString [

	^ SetContentTypeCommand to: aString
]
