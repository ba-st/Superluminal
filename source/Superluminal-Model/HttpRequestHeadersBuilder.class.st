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
HttpRequestHeadersBuilder >> setAuthorizationTo: anAuthorizationDirective [

	^ SetAuthorizationHeaderCommand to: anAuthorizationDirective
]

{ #category : #configuring }
HttpRequestHeadersBuilder >> setBearerTokenTo: aBearerToken [

	^ SetAuthorizationHeaderCommand toBearerToken: aBearerToken
]

{ #category : #configuring }
HttpRequestHeadersBuilder >> setIfMatchTo: anEntityTag [

	^ SetIfMatchCommand to: anEntityTag
]

{ #category : #configuring }
HttpRequestHeadersBuilder >> setIfNoneMatchTo: anEntityTag [

	^ SetIfNoneMatchCommand to: anEntityTag
]
