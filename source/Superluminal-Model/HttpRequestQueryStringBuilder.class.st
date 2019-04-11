Class {
	#name : #HttpRequestQueryStringBuilder,
	#superclass : #Object,
	#instVars : [
		'commands'
	],
	#category : #'Superluminal-Model-Builders'
}

{ #category : #building }
HttpRequestQueryStringBuilder >> build [

	^ CompositeHttpRequestCommand ofAll: commands
]

{ #category : #configuring }
HttpRequestQueryStringBuilder >> fieldNamed: aName pairedTo: aValue [

	commands add: (AddQueryStringFieldCommand named: aName pairedTo: aValue)
]

{ #category : #initialization }
HttpRequestQueryStringBuilder >> initialize [

	commands := OrderedCollection new
]
