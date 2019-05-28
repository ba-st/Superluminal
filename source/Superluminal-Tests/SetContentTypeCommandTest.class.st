Class {
	#name : #SetContentTypeCommandTest,
	#superclass : #TestCase,
	#category : #'Superluminal-Tests-Commands'
}

{ #category : #tests }
SetContentTypeCommandTest >> testApplyOnWithMediaType [

	| httpClient command |

	httpClient := ZnClient new.
	( SetBodyCommand to: ( ZnStringEntity json: '[]' ) ) applyOn: httpClient.

	command := SetContentTypeCommand to: 'application/vnd.mercap.objective+json'asMediaType.
	command applyOn: httpClient.

	self
		assert: httpClient request contentType
		equals: 'application/vnd.mercap.objective+json' asMediaType
]

{ #category : #tests }
SetContentTypeCommandTest >> testApplyOnWithString [

	| httpClient command |

	httpClient := ZnClient new.
	( SetBodyCommand to: ( ZnStringEntity json: '[]' ) ) applyOn: httpClient.

	command := SetContentTypeCommand to: 'application/vnd.mercap.objective+json'.
	command applyOn: httpClient.

	self
		assert: httpClient request contentType
		equals: 'application/vnd.mercap.objective+json' asMediaType
]
