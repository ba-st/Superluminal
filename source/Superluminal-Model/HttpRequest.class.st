Class {
	#name : #HttpRequest,
	#superclass : #Object,
	#instVars : [
		'commands',
		'url',
		'method'
	],
	#category : #'Superluminal-Model-Core'
}

{ #category : #'instance creation' }
HttpRequest class >> get: aLocation [ 

	^ self performing: #GET on: aLocation configuredUsing: []
]

{ #category : #'instance creation' }
HttpRequest class >> get: aLocation configuredUsing: aMonadycBlock [
	
	^ self performing: #GET on: aLocation configuredUsing: aMonadycBlock 
]

{ #category : #'instance creation' }
HttpRequest class >> performing: anHttpMethod on: aLocation configuredUsing: aMonadycBlock [ 
	
	^ self new initializePerforming: anHttpMethod on: aLocation configuredUsing: aMonadycBlock 
]

{ #category : #'instance creation' }
HttpRequest class >> post: aLocation configuredUsing: aMonadycBlock [

	 ^ self performing: #POST on: aLocation configuredUsing: aMonadycBlock
]

{ #category : #applying }
HttpRequest >> applyOn: anHttpClient [

	anHttpClient request: ( ZnRequest method: method url: url ).

	commands ifNotNil: [ commands applyOn: anHttpClient ].

	^ anHttpClient
		execute;
		response
]

{ #category : #initialization }
HttpRequest >> initializePerforming: anHttpMethod on: aLocation configuredUsing: aMonadycBlock [

	| configurator |

	method := anHttpMethod.
	url := aLocation.

	configurator := HttpRequestBuilder new.
	commands := aMonadycBlock cull: configurator
]
