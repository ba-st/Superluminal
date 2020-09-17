Class {
	#name : #CompositeHttpRequestCommand,
	#superclass : #HttpRequestCommand,
	#instVars : [
		'commands'
	],
	#category : #'Superluminal-Model-Commands'
}

{ #category : #'instance creation' }
CompositeHttpRequestCommand class >> empty [
	
	^ self ofAll: #()
]

{ #category : #'instance creation' }
CompositeHttpRequestCommand class >> ofAll: aCommandCollection [
	
	^ self new initializeOfAll: aCommandCollection 
]

{ #category : #applying }
CompositeHttpRequestCommand >> applyOn: httpClient [

	commands do: [ :command | command applyOn: httpClient ]
]

{ #category : #private }
CompositeHttpRequestCommand >> commands [

	^ commands
]

{ #category : #initialization }
CompositeHttpRequestCommand >> initializeOfAll: aCommandCollection [ 
	
	commands := aCommandCollection 
]
