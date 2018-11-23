Class {
	#name : #FormUrlEncodedBodyBuilder,
	#superclass : #Object,
	#instVars : [
		'commands'
	],
	#category : #'Nap-Model-Builders'
}

{ #category : #building }
FormUrlEncodedBodyBuilder >> build [

	^ CompositeHttpRequestCommand ofAll: commands
]

{ #category : #configuring }
FormUrlEncodedBodyBuilder >> fieldNamed: aName pairedTo: aValue [

	commands add: (AddFormFieldCommand named: aName pairedTo: aValue)
]

{ #category : #initialization }
FormUrlEncodedBodyBuilder >> initialize [

	commands := OrderedCollection new
]
