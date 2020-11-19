Class {
	#name : #DistributedMemoryCacheRepositoryTest,
	#superclass : #CacheRepositoryTest,
	#instVars : [
		'memcached'
	],
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #initialization }
DistributedMemoryCacheRepositoryTest >> setUpRepository [

	repository := DistributedMemoryCacheRepository
		using: dateTimeProvider
		persistingTo: ( MDCacheClient onServers: {'127.0.0.1:11211'} )
]

{ #category : #tests }
DistributedMemoryCacheRepositoryTest >> waitFor: aDuration [

	currentDateTime := dateTime + aDuration.
	aDuration asDelay wait.
]
