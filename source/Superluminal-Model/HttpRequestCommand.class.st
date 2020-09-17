Class {
	#name : #HttpRequestCommand,
	#superclass : #Object,
	#category : #'Superluminal-Model-Commands'
}

{ #category : #composing }
HttpRequestCommand >> + anHttpRequestCommand [

	^ CompositeHttpRequestCommand ofAll: (Array with: self with: anHttpRequestCommand)
]

{ #category : #applying }
HttpRequestCommand >> applyOn: httpClient [

	self subclassResponsibility 
]
