Class {
	#name : #ExpiringCache,
	#superclass : #Object,
	#instVars : [
		'expiringResources'
	],
	#category : #'Superluminal-RESTfulAPI-Cache'
}

{ #category : #'instance creation' }
ExpiringCache class >> onDistributedMemoryAt: aLocationSet [

	^ self
		persistingTo:
			( DistributedMemoryCacheRepository
				using: [ DateAndTime now ]
				persistingTo: ( MDCacheClient onServers: aLocationSet ) )
]

{ #category : #'instance creation' }
ExpiringCache class >> onLocalMemory [

	^ self persistingTo: ( LocalMemoryCacheRepository using: [ DateAndTime now ] )
]

{ #category : #'private - instance creation' }
ExpiringCache class >> persistingTo: aRepository [

	^ self new initializePersistingTo: aRepository
]

{ #category : #accessing }
ExpiringCache >> clearResourceAt: aLocation [

	expiringResources remove: aLocation asUrl asString
]

{ #category : #initialization }
ExpiringCache >> initializePersistingTo: aRepository [

	expiringResources := aRepository
]

{ #category : #accessing }
ExpiringCache >> withResourceAt: aBuiltKey obtainedUsing: aGetBlock do: aProcessBlock [

	| resource |

	[ resource := expiringResources get: aBuiltKey ]
		on: KeyNotFound
		do: [ :signal | 
			resource := aGetBlock value.
			expiringResources store: resource at: aBuiltKey
			].

	^ aProcessBlock value: resource contents
]
