Class {
	#name : #HttpRequestCommand,
	#superclass : #Object,
	#category : #'Nap-Model-Commands'
}

{ #category : #composing }
HttpRequestCommand >> + aNapCommand [

	^ CompositeHttpRequestCommand ofAll: (Array with: self with: aNapCommand)
]

{ #category : #applying }
HttpRequestCommand >> applyOn: aNap [

	self subclassResponsibility 
]
