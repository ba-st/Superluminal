Class {
	#name : #LocalMemoryCacheRepository,
	#superclass : #CacheRepository,
	#instVars : [
		'expiringResources',
		'currentTimeProvider'
	],
	#category : #'Superluminal-RESTfulAPI-Cache'
}

{ #category : #'instance creation' }
LocalMemoryCacheRepository class >> using: aTimeSourceProvider [
	
	^ self new initializeUsing: aTimeSourceProvider
]

{ #category : #querying }
LocalMemoryCacheRepository >> get: aKey [

	^ expiringResources
		at: aKey
		ifPresent: [ :resource | 
			( resource isExpiredAt: self now )
				ifTrue: [ 
					self remove: aKey.
					KeyNotFound signal: ( '<1p> not found' expandMacrosWith: aKey )
					]
				ifFalse: [ resource ]
			]
		ifAbsent: [ KeyNotFound signal: ( '<1p> not found' expandMacrosWith: aKey ) ]
]

{ #category : #initialization }
LocalMemoryCacheRepository >> initializeUsing: aTimeSourceProvider [ 
 	
	expiringResources := Dictionary new.
	currentTimeProvider := aTimeSourceProvider
]

{ #category : #'private - accessing' }
LocalMemoryCacheRepository >> now [

	^ currentTimeProvider value
]

{ #category : #management }
LocalMemoryCacheRepository >> remove: aKey [
	
	expiringResources removeKey: aKey ifAbsent: [ ]
]

{ #category : #management }
LocalMemoryCacheRepository >> store: anExpiringResource at: aKey [

	anExpiringResource
		withTimeToExpireAt: self now
		do: [ :timeToExpire | expiringResources at: aKey put: anExpiringResource ]
]
