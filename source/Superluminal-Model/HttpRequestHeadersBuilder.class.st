Class {
	#name : #HttpRequestHeadersBuilder,
	#superclass : #Object,
	#category : #'Superluminal-Model-Builders'
}

{ #category : #supplying }
HttpRequestHeadersBuilder >> setAcceptTo: aMediaType [
	
	^ SetAcceptMediaTypeCommand to: aMediaType 
]

{ #category : #configuring }
HttpRequestHeadersBuilder >> setBearerTokenTo: anOAuth2AccessToken [

	^ SetBearerTokenCommand to: anOAuth2AccessToken
]
