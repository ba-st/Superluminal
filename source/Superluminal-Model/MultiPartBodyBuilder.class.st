Class {
	#name : 'MultiPartBodyBuilder',
	#superclass : 'Object',
	#instVars : [
		'commands'
	],
	#category : 'Superluminal-Model-Builders',
	#package : 'Superluminal-Model',
	#tag : 'Builders'
}

{ #category : 'building' }
MultiPartBodyBuilder >> build [

	^ CompositeHttpRequestCommand ofAll: commands
]

{ #category : 'configuring' }
MultiPartBodyBuilder >> fieldNamed: aName attaching: aFile [

	commands add: ( AddMultiPartCommand named: aName attaching: aFile )
]

{ #category : 'configuring' }
MultiPartBodyBuilder >> fieldNamed: aName pairedTo: aValue [

	commands add: ( AddMultiPartCommand named: aName pairedTo: aValue )
]

{ #category : 'building' }
MultiPartBodyBuilder >> initialize [

	super initialize.
	commands := OrderedCollection new
]
