Class {
	#name : #SetBearerTokenCommand,
	#superclass : #HttpRequestCommand,
	#instVars : [
		'token'
	],
	#category : #'Superluminal-Model-Commands'
}

{ #category : #'instance creation' }
SetBearerTokenCommand class >> to: anOAuth2AccessToken [ 
	
	^ self new initializeTo: anOAuth2AccessToken 
]

{ #category : #applying }
SetBearerTokenCommand >> applyOn: httpClient [

	httpClient headerAt: #Authorization put: ( #'Bearer <1p>' expandMacrosWith: token )
]

{ #category : #initialization }
SetBearerTokenCommand >> initializeTo: anOAuth2AccessToken [ 
	
	token := anOAuth2AccessToken 
]
