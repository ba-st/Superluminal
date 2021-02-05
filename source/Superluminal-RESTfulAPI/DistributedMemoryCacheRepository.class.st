Class {
	#name : #DistributedMemoryCacheRepository,
	#superclass : #CacheRepository,
	#instVars : [
		'expiringResources',
		'currentTimeProvider'
	],
	#category : #'Superluminal-RESTfulAPI-Cache'
}

{ #category : #initializaiton }
DistributedMemoryCacheRepository class >> using: aTimeSource persistingTo: aMemcachedClient [
	
	^ self new initializeUsing: aTimeSource persistingTo: aMemcachedClient 
]

{ #category : #querying }
DistributedMemoryCacheRepository >> get: aKey [

	| resource |

	resource := expiringResources get: aKey.
	resource ifNil: [ KeyNotFound signal: ( '<1p> not found' expandMacrosWith: aKey ) ].
	^ resource
]

{ #category : #initialization }
DistributedMemoryCacheRepository >> initializeUsing: aTimeSource persistingTo: aMemcachedClient [

	currentTimeProvider := aTimeSource.
	expiringResources := aMemcachedClient 
]

{ #category : #management }
DistributedMemoryCacheRepository >> now [

	^ currentTimeProvider value
]

{ #category : #management }
DistributedMemoryCacheRepository >> remove: aKey [
	
	^ expiringResources remove: aKey
]

{ #category : #management }
DistributedMemoryCacheRepository >> store: anExpiringResource at: aKey [

	anExpiringResource
		withTimeToExpireAt: self now
		do: [ :timeToExpire | 
			expiringResources 
				set: aKey 
				value: anExpiringResource 
				expires: timeToExpire ]
]
