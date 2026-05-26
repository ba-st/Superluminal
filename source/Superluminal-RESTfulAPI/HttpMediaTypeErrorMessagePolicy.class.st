Class {
	#name : 'HttpMediaTypeErrorMessagePolicy',
	#superclass : 'Object',
	#instVars : [
		'mediaType',
		'extractorBlock'
	],
	#category : 'Superluminal-RESTfulAPI-Core',
	#package : 'Superluminal-RESTfulAPI',
	#tag : 'Core'
}

{ #category : 'instance creation' }
HttpMediaTypeErrorMessagePolicy class >> handling: aMediaType extractingMessageWith: aBlock [

  ^ self new initializeHandling: aMediaType extractingMessageWith: aBlock
]

{ #category : 'testing' }
HttpMediaTypeErrorMessagePolicy >> canHandle: aResponse [

  ^ aResponse contentType
      ifNotNil: [ :contentType | contentType matches: mediaType ]
      ifNil: [ false ]
]

{ #category : 'processing' }
HttpMediaTypeErrorMessagePolicy >> errorMessageFrom: aResponse [

  ^ extractorBlock value: aResponse
]

{ #category : 'initialization' }
HttpMediaTypeErrorMessagePolicy >> initializeHandling: aMediaType extractingMessageWith: aBlock [

  mediaType := aMediaType.
  extractorBlock := aBlock
]
