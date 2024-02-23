Class {
	#name : 'HttpRequest',
	#superclass : 'Object',
	#instVars : [
		'url',
		'method',
		'command'
	],
	#category : 'Superluminal-Model-Core',
	#package : 'Superluminal-Model',
	#tag : 'Core'
}

{ #category : 'instance creation' }
HttpRequest class >> delete: aLocation configuredUsing: aBlock [
	
	^ self performing: #DELETE on: aLocation configuredUsing: aBlock 
]

{ #category : 'instance creation' }
HttpRequest class >> get: aLocation [

	^ self get: aLocation configuredUsing: [  ]
]

{ #category : 'instance creation' }
HttpRequest class >> get: aLocation configuredUsing: aBlock [
	
	^ self performing: #GET on: aLocation configuredUsing: aBlock 
]

{ #category : 'instance creation' }
HttpRequest class >> patch: aLocation configuredUsing: aBlock [

	 ^ self performing: #PATCH on: aLocation configuredUsing: aBlock
]

{ #category : 'private' }
HttpRequest class >> performing: anHttpMethod on: aLocation configuredUsing: aBlock [ 
	
	^ self new initializePerforming: anHttpMethod on: aLocation asUrl configuredUsing: aBlock 
]

{ #category : 'instance creation' }
HttpRequest class >> post: aLocation configuredUsing: aBlock [

	 ^ self performing: #POST on: aLocation configuredUsing: aBlock
]

{ #category : 'instance creation' }
HttpRequest class >> put: aLocation configuredUsing: aBlock [

	 ^ self performing: #PUT on: aLocation configuredUsing: aBlock
]

{ #category : 'applying' }
HttpRequest >> applyOn: httpClient [

	httpClient
		resetRequest;
		method: method;
		url: url.

	command applyOn: httpClient.

	^ httpClient
		execute;
		response
]

{ #category : 'initialization' }
HttpRequest >> initializePerforming: anHttpMethod on: aLocation configuredUsing: aBlock [

	method := anHttpMethod.
	url := aLocation.
	command := aBlock asHttpRequestCommand
]
