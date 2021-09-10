Class {
	#name : #SetBodyCommandTest,
	#superclass : #TestCase,
	#category : #'Superluminal-Model-Tests-Commands'
}

{ #category : #tests }
SetBodyCommandTest >> testApplyOn [

	| httpClient command json |

	httpClient := ZnClient new.
	json := '{"last_name":"fox","first_name":"fran"}'.
	command := SetBodyCommand to: (ZnStringEntity json: json).
	command applyOn: httpClient.

	self
		assert: httpClient request contentLength equals: json size;
		assert: httpClient request contentType equals: 'application/json' asMediaType;
		assert: httpClient request contents equals: json
]

{ #category : #tests }
SetBodyCommandTest >> testApplyOnUsingMimeType [

	| httpClient command json |

	httpClient := ZnClient new.
	json := '{"last_name":"fox","first_name":"fran"}'.
	command := SetBodyCommand to: ( ZnEntity with: json type: 'application/vnd.mercap.objective+json' asMediaType ).
	command applyOn: httpClient.

	self
		assert: httpClient request contentLength equals: json size;
		assert: httpClient request contentType equals: 'application/vnd.mercap.objective+json' asMediaType;
		assert: httpClient request contents equals: json
]
