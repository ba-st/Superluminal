Class {
	#name : #HttpRequestHeadersSupplier,
	#superclass : #Object,
	#category : #'Nap-Model-Builders'
}

{ #category : #supplying }
HttpRequestHeadersSupplier >> setAcceptTo: aMediaType [
	
	^ SetAcceptMediaTypeCommand to: aMediaType 
]
