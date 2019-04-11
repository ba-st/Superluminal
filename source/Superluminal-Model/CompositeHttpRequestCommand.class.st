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

{ #category : #composing }
CompositeHttpRequestCommand >> + aCommand [

	^ self class
		ofAll:
			(OrderedCollection new
				addAll: commands;
				add: aCommand;
				yourself)
]

{ #category : #applying }
CompositeHttpRequestCommand >> applyOn: anHttpClient [

	commands do: [ :command | command applyOn: anHttpClient ]
]

{ #category : #initialization }
CompositeHttpRequestCommand >> initializeOfAll: aCommandCollection [ 
	
	commands := aCommandCollection 
]
