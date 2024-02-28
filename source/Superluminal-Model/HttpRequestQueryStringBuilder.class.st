Class {
	#name : 'HttpRequestQueryStringBuilder',
	#superclass : 'Object',
	#instVars : [
		'commands'
	],
	#category : 'Superluminal-Model-Builders',
	#package : 'Superluminal-Model',
	#tag : 'Builders'
}

{ #category : 'building' }
HttpRequestQueryStringBuilder >> build [

	^ CompositeHttpRequestCommand ofAll: commands
]

{ #category : 'configuring' }
HttpRequestQueryStringBuilder >> fieldNamed: aName pairedTo: aValue [

	commands add: (AddQueryStringFieldCommand named: aName pairedTo: aValue)
]

{ #category : 'initialization' }
HttpRequestQueryStringBuilder >> initialize [

	super initialize.
	commands := OrderedCollection new
]
