Class {
	#name : 'HttpErrorMessageBuilder',
	#superclass : 'Object',
	#instVars : [
		'errorMessageBuilderByMediaType'
	],
	#category : 'Superluminal-RESTfulAPI-Builders',
	#package : 'Superluminal-RESTfulAPI',
	#tag : 'Builders'
}

{ #category : 'configuration' }
HttpErrorMessageBuilder >> errorMessageFrom: aResponse ifNone: aNoneBlock [

  aResponse contentType ifNotNil: [ :contentType |
      errorMessageBuilderByMediaType keysAndValuesDo: [ :mediaType :block |
          ( contentType matches: mediaType ) ifTrue: [ ^ block value: aResponse ] ]
    ].

  ^ aNoneBlock value
]

{ #category : 'initialization' }
HttpErrorMessageBuilder >> initialize [

  errorMessageBuilderByMediaType := Dictionary new
]

{ #category : 'configuration' }
HttpErrorMessageBuilder >> whenReceiving: aMediaType extractApplying: aBlock [

  errorMessageBuilderByMediaType at: aMediaType put: aBlock
]
