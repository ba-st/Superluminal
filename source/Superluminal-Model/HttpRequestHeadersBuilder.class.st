Class {
	#name : 'HttpRequestHeadersBuilder',
	#superclass : 'Object',
	#category : 'Superluminal-Model-Builders',
	#package : 'Superluminal-Model',
	#tag : 'Builders'
}

{ #category : 'configuring' }
HttpRequestHeadersBuilder >> set: aHeaderName to: aHeaderValue [

	^ SetHeaderCommand setting: aHeaderName to: aHeaderValue
]

{ #category : 'configuring' }
HttpRequestHeadersBuilder >> setAcceptTo: aMediaType [
	
	^ SetAcceptMediaTypeCommand to: aMediaType 
]

{ #category : 'configuring' }
HttpRequestHeadersBuilder >> setAuthorizationTo: anAuthorizationDirective [

	^ SetHeaderCommand settingAuthorizationTo: anAuthorizationDirective
]

{ #category : 'configuring' }
HttpRequestHeadersBuilder >> setBearerTokenTo: aBearerToken [

	^ SetHeaderCommand settingAuthorizationToBearerToken: aBearerToken
]

{ #category : 'configuring' }
HttpRequestHeadersBuilder >> setIfMatchTo: anEntityTag [

	^ SetIfMatchCommand to: anEntityTag
]

{ #category : 'configuring' }
HttpRequestHeadersBuilder >> setIfNoneMatchTo: anEntityTag [

	^ SetIfNoneMatchCommand to: anEntityTag
]
