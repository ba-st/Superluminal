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
		              persistingTo:
		              ( MDCacheClient onServers:
			                { '<1s>:11211' expandMacrosWith: self memcachedHostname } )
]

{ #category : 'running' }
DistributedMemoryCacheRepositoryTest >> waitFor: aDuration [

	currentDateTime := currentDateTime + aDuration.
	aDuration wait.
]
