Class {
	#name : #DistributedMemoryCacheRepositoryTest,
	#superclass : #CacheRepositoryTest,
	#instVars : [
		'memcached'
	],
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #running }
DistributedMemoryCacheRepositoryTest >> setUpRepository [

	repository := DistributedMemoryCacheRepository
		using: dateTimeProvider
		persistingTo: ( MDCacheClient onServers: {'127.0.0.1:11211'} )
]

{ #category : #private }
DistributedMemoryCacheRepositoryTest >> waitFor: aDuration [

	currentDateTime := dateTime + aDuration.
	aDuration asDelay wait.
]
