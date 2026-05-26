Class {
	#name : 'HttpErrorHandlingPolicyBuilder',
	#superclass : 'Object',
	#instVars : [
		'policies'
	],
	#category : 'Superluminal-RESTfulAPI-Builders',
	#package : 'Superluminal-RESTfulAPI',
	#tag : 'Builders'
}

{ #category : 'building' }
HttpErrorHandlingPolicyBuilder >> build [

  ^ CompositeHttpErrorMessagePolicy ofAll: policies
]

{ #category : 'initialization' }
HttpErrorHandlingPolicyBuilder >> initialize [

  super initialize.

  policies := OrderedCollection new
]

{ #category : 'configuration' }
HttpErrorHandlingPolicyBuilder >> whenReceivingMediaType: aMediaType extractMessageApplying: aBlock [

  policies add:
    ( HttpMediaTypeErrorMessagePolicy handling: aMediaType extractingMessageWith: aBlock )
]
