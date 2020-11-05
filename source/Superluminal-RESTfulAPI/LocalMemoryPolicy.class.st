Class {
	#name : #LocalMemoryPolicy,
	#superclass : #Object,
	#instVars : [
		'timeSource',
		'expiringResources'
	],
	#category : #'Superluminal-RESTfulAPI-Cache'
}

{ #category : #'instance creation' }
LocalMemoryPolicy class >> accordingTo: aTimeSource [
	
	^ self new initializeAccordingTo: aTimeSource
]

{ #category : #'as yet unclassified' }
LocalMemoryPolicy >> get: aBuiltKey [

	^ expiringResources
		at: aBuiltKey
		ifPresent: [ :resource | 
			( resource isExpiredAt: timeSource value )
				ifTrue: [ nil ]
				ifFalse: [ resource ] ]
]

{ #category : #initialization }
LocalMemoryPolicy >> initializeAccordingTo: aTimeSource [ 
 	
	expiringResources := Dictionary new.
	timeSource := aTimeSource
]

{ #category : #'as yet unclassified' }
LocalMemoryPolicy >> store: anExpiringResource at: aBuiltKey [

	"anExpiringResource storeLocallyOn: expiringResources at: aBuiltKey"
	expiringResources at: aBuiltKey put: anExpiringResource
]
