Class {
	#name : #DistributedMemoryCacheRepository,
	#superclass : #CacheRepository,
	#instVars : [
		'timeSource',
		'expiringResources'
	],
	#category : #'Superluminal-RESTfulAPI-Cache'
}

{ #category : #initializaiton }
DistributedMemoryCacheRepository class >> using: aTimeSource persistingTo: aMemcachedClient [
	
	^ self new initializeUsing: aTimeSource persistingTo: aMemcachedClient 
]

{ #category : #querying }
DistributedMemoryCacheRepository >> get: aBuiltKey [

	| resource |

	resource := expiringResources get: aBuiltKey.
	resource isNil then: [ KeyNotFound signal: ( '<1p> not found' expandMacrosWith: aBuiltKey ) ].
	^ resource
]

{ #category : #initialization }
DistributedMemoryCacheRepository >> initializeUsing: aTimeSource persistingTo: aMemcachedClient [

	timeSource := aTimeSource.
	expiringResources := aMemcachedClient 
]

{ #category : #management }
DistributedMemoryCacheRepository >> remove: aKey [
	
	^ expiringResources remove: aKey
]

{ #category : #management }
DistributedMemoryCacheRepository >> store: anExpiringResource at: aKey [

	expiringResources
		set: aKey
		value: anExpiringResource 
		expires: ( anExpiringResource expiresIn: timeSource value )
]
