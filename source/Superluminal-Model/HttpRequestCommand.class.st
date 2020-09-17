Class {
	#name : #HttpRequestCommand,
	#superclass : #Object,
	#category : #'Superluminal-Model-Commands'
}

{ #category : #composing }
HttpRequestCommand >> + anHttpRequestCommand [

	^ CompositeHttpRequestCommand ofAll: self commands , anHttpRequestCommand commands
]

{ #category : #applying }
HttpRequestCommand >> applyOn: httpClient [

	self subclassResponsibility 
]

{ #category : #private }
HttpRequestCommand >> commands [

	 ^Array with: self 
]
