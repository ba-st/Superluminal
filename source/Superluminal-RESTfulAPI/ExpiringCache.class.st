"
I'm a high-speed data storage layer which stores a set of resources, typically transient in nature, so that future requests for that resources are served up faster than is possible by accessing its primary storage location.

I can store resources on locally by collaborating with a LocalMemoryCacheRespository or remotly using a DistribuedMemoryCacheRepository instead.
"
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

	resource := [ expiringResources get: aBuiltKey ]
		            on: KeyNotFound
		            do: [ :notFound |
			            | obtainedResource |

			            obtainedResource := aGetBlock value.
			            obtainedResource canBeStored then: [
				            expiringResources store: obtainedResource at: aBuiltKey ].
			            notFound return: obtainedResource
			            ].

	^ aProcessBlock value: resource contents
]
