Class {
	#name : #DistributedMemoryBasedExpiringCacheTest,
	#superclass : #ExpiringCacheTest,
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #'as yet unclassified' }
DistributedMemoryBasedExpiringCacheTest >> setUpExpiringCache [
	
	| memcached |
	memcached := MDCacheClient onServers: {'127.0.0.1:11211'}.
	cache := ExpiringCache persistingTo: (DistributedMemoryCacheRepository using: dateTimeProvider persistingTo: memcached).
]

{ #category : #'as yet unclassified' }
DistributedMemoryBasedExpiringCacheTest >> waitFor: aDuration [

	currentDateTime := currentDateTime + aDuration.
	aDuration asDelay wait.
]
