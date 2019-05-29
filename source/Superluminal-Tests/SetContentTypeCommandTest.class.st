Class {
	#name : #SetContentTypeCommandTest,
	#superclass : #TestCase,
	#category : #'Superluminal-Tests-Commands'
}

{ #category : #tests }
SetContentTypeCommandTest >> testApplyOnUsingMimeType [

	| httpClient command |

	httpClient := ZnClient new.
	( SetBodyCommand to: ( ZnStringEntity json: '[]' ) ) applyOn: httpClient.

	command := SetContentTypeCommand to: 'application/vnd.mercap.objective+json' asZnMimeType.
	command applyOn: httpClient.

	self
		assert: httpClient request contentType
		equals: 'application/vnd.mercap.objective+json' asZnMimeType
]

{ #category : #tests }
SetContentTypeCommandTest >> testApplyOnUsingString [

	| httpClient command |

	httpClient := ZnClient new.
	( SetBodyCommand to: ( ZnStringEntity json: '[]' ) ) applyOn: httpClient.

	command := SetContentTypeCommand to: 'application/vnd.mercap.objective+json'.
	command applyOn: httpClient.

	self
		assert: httpClient request contentType
		equals: 'application/vnd.mercap.objective+json' asZnMimeType
]
