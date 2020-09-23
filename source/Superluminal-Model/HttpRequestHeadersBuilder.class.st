Class {
	#name : #HttpRequestHeadersBuilder,
	#superclass : #Object,
	#category : #'Superluminal-Model-Builders'
}

{ #category : #configuring }
HttpRequestHeadersBuilder >> setAcceptTo: aMediaType [
	
	^ SetAcceptMediaTypeCommand to: aMediaType 
]

{ #category : #configuring }
HttpRequestHeadersBuilder >> setBearerTokenTo: anOAuth2AccessToken [

	^ SetBearerTokenCommand to: anOAuth2AccessToken
]

{ #category : #configuring }
HttpRequestHeadersBuilder >> setIfMatchTo: anEntityTag [

	^ SetIfMatchCommand to: anEntityTag
]

{ #category : #configuring }
HttpRequestHeadersBuilder >> setIfNoneMatchTo: anEntityTag [

	^ SetIfNoneMatchCommand to: anEntityTag
]
