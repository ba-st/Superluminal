Class {
	#name : #SetBasicAuthenticationCommand,
	#superclass : #HttpRequestCommand,
	#instVars : [
		'username',
		'password'
	],
	#category : #'Superluminal-Model-Commands'
}

{ #category : #'instance creation' }
SetBasicAuthenticationCommand class >> with: aUsername password: aPassword [
	
	^ self new initializeWith: aUsername password: aPassword
]

{ #category : #applying }
SetBasicAuthenticationCommand >> applyOn: httpClient [

	httpClient username: username password: password
]

{ #category : #initialization }
SetBasicAuthenticationCommand >> initializeWith: aUsername password: aPassword [

	username := aUsername.
	password := aPassword
]
