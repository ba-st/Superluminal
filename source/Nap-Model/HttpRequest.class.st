Class {
	#name : #HttpRequest,
	#superclass : #Object,
	#instVars : [
		'commands',
		'url',
		'method'
	],
	#category : #'Nap-Model-Core'
}

{ #category : #'instance creation' }
HttpRequest class >> get: aUrl [ 

	^ self performing: #GET at: aUrl configuredUsing: []
]

{ #category : #'instance creation' }
HttpRequest class >> get: aUrl configuredUsing: aMonadycBlock [
	
	^ self performing: #GET at: aUrl configuredUsing: aMonadycBlock 
]

{ #category : #'instance creation' }
HttpRequest class >> performing: anHttpMethod at: aUrl configuredUsing: aMonadycBlock [ 
	
	^ self new initializePerforming: anHttpMethod at: aUrl configuredUsing: aMonadycBlock 
]

{ #category : #'instance creation' }
HttpRequest class >> post: aUrl configuredUsing: aMonadycBlock [

	 ^ self performing: #POST at: aUrl configuredUsing: aMonadycBlock
]

{ #category : #applying }
HttpRequest >> applyOn: anHttpClient [

	anHttpClient
		url: url;
		method: method.

	commands isNil ifFalse: [ commands applyOn: anHttpClient ].

	^ anHttpClient
		execute;
		response
]

{ #category : #initialization }
HttpRequest >> initializePerforming: anHttpMethod at: aUrl configuredUsing: aMonadycBlock [

	| configurator |

	method := anHttpMethod.
	url := aUrl.

	configurator := HttpRequestConfigurator new.
	commands := aMonadycBlock cull: configurator
]
