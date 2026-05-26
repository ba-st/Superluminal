Class {
	#name : 'CompositeHttpErrorMessagePolicy',
	#superclass : 'Object',
	#instVars : [
		'policies'
	],
	#category : 'Superluminal-RESTfulAPI-Core',
	#package : 'Superluminal-RESTfulAPI',
	#tag : 'Core'
}

{ #category : 'instance creation' }
CompositeHttpErrorMessagePolicy class >> ofAll: aPolicyCollection [

  ^ self new initializeOfAll: aPolicyCollection
]

{ #category : 'processing' }
CompositeHttpErrorMessagePolicy >> errorMessageFrom: aResponse ifNone: aNoneBlock [

  ^ policies
      detect: [ :policy | policy canHandle: aResponse ]
      ifFound: [ :policy | policy errorMessageFrom: aResponse ]
      ifNone: aNoneBlock
]

{ #category : 'initialization' }
CompositeHttpErrorMessagePolicy >> initializeOfAll: aPolicyCollection [

  policies := aPolicyCollection
]
