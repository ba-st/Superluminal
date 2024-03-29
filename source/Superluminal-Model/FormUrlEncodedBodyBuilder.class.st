Class {
	#name : 'FormUrlEncodedBodyBuilder',
	#superclass : 'Object',
	#instVars : [
		'commands'
	],
	#category : 'Superluminal-Model-Builders',
	#package : 'Superluminal-Model',
	#tag : 'Builders'
}

{ #category : 'building' }
FormUrlEncodedBodyBuilder >> build [

	^ CompositeHttpRequestCommand ofAll: commands
]

{ #category : 'configuring' }
FormUrlEncodedBodyBuilder >> fieldNamed: aName pairedTo: aValue [

	commands add: (AddFormFieldCommand named: aName pairedTo: aValue)
]

{ #category : 'initialization' }
FormUrlEncodedBodyBuilder >> initialize [

	super initialize.
	commands := OrderedCollection new
]
