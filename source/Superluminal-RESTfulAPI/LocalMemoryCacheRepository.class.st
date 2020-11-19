Class {
	#name : #LocalMemoryCacheRepository,
	#superclass : #CacheRepository,
	#instVars : [
		'expiringResources',
		'timeSourceProvider'
	],
	#category : #'Superluminal-RESTfulAPI-Cache'
}

{ #category : #'instance creation' }
LocalMemoryCacheRepository class >> using: aTimeSourceProvider [
	
	^ self new initializeUsing: aTimeSourceProvider
]

{ #category : #querying }
LocalMemoryCacheRepository >> get: aBuiltKey [

	^ expiringResources
		at: aBuiltKey
		ifPresent: [ :resource | 
			( resource isExpiredAt: self now )
				ifTrue: [ KeyNotFound signal: ( '<1p> not found' expandMacrosWith: aBuiltKey ) ]
				ifFalse: [ resource ]
			]
		ifAbsent: [ KeyNotFound signal: ( '<1p> not found' expandMacrosWith: aBuiltKey ) ]
]

{ #category : #initialization }
LocalMemoryCacheRepository >> initializeUsing: aTimeSourceProvider [ 
 	
	expiringResources := Dictionary new.
	timeSourceProvider := aTimeSourceProvider
]

{ #category : #'private - accessing' }
LocalMemoryCacheRepository >> now [

	^ timeSourceProvider value
]

{ #category : #management }
LocalMemoryCacheRepository >> remove: aKey [
	
	expiringResources removeKey: aKey ifAbsent: [ ]
]

{ #category : #management }
LocalMemoryCacheRepository >> store: anExpiringResource at: aKey [

	expiringResources at: aKey put: anExpiringResource
]
