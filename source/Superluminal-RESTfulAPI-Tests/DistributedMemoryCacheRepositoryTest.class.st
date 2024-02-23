Class {
	#name : 'DistributedMemoryCacheRepositoryTest',
	#superclass : 'CacheRepositoryTest',
	#instVars : [
		'memcached'
	],
	#category : 'Superluminal-RESTfulAPI-Tests-Cache',
	#package : 'Superluminal-RESTfulAPI-Tests',
	#tag : 'Cache'
}

{ #category : 'running' }
DistributedMemoryCacheRepositoryTest >> setUpRepository [

	repository := DistributedMemoryCacheRepository
		using: currentTimeProvider
		persistingTo: ( MDCacheClient onServers: {'127.0.0.1:11211'} )
]

{ #category : 'private' }
DistributedMemoryCacheRepositoryTest >> waitFor: aDuration [

	currentDateTime := currentDateTime + aDuration.
	aDuration asDelay wait.
]
