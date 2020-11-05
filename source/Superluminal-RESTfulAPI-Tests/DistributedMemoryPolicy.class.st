Class {
	#name : #DistributedMemoryPolicy,
	#superclass : #Object,
	#instVars : [
		'timeSource',
		'expiringResources'
	],
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #initializaiton }
DistributedMemoryPolicy class >> accordingTo: aTimeSource storingOn: aMemcachedClient [
	
	self flag: 'rename de esto storingResourcesOn: aMemcachedClient using: '.
	^ self new initializeAccordingTo: aTimeSource storingOn: aMemcachedClient 
]

{ #category : #initialization }
DistributedMemoryPolicy >> initializeAccordingTo: aTimeSource storingOn: aMemcachedClient [

	timeSource := aTimeSource.
	expiringResources := aMemcachedClient 
]

{ #category : #'as yet unclassified' }
DistributedMemoryPolicy >> store: anExpiringResource at: aBuiltKey [

	anExpiringResource store: self onDistributedMemoryAt: aBuiltKey at: timeSource value
]
