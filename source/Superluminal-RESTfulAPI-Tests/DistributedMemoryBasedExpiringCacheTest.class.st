Class {
	#name : 'DistributedMemoryBasedExpiringCacheTest',
	#superclass : 'ExpiringCacheTest',
	#category : 'Superluminal-RESTfulAPI-Tests-Cache',
	#package : 'Superluminal-RESTfulAPI-Tests',
	#tag : 'Cache'
}

{ #category : 'running' }
DistributedMemoryBasedExpiringCacheTest >> setUpExpiringCache [
	
	| memcached |
	memcached := MDCacheClient onServers: {'127.0.0.1:11211'}.
	cache := ExpiringCache persistingTo: (DistributedMemoryCacheRepository using: currentTimeProvider persistingTo: memcached).
]

{ #category : 'private' }
DistributedMemoryBasedExpiringCacheTest >> waitFor: aDuration [

	currentDateTime := currentDateTime + aDuration.
	aDuration wait.
]
