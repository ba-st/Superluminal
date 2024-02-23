Class {
	#name : 'LocalMemoryCacheRepositoryTest',
	#superclass : 'CacheRepositoryTest',
	#category : 'Superluminal-RESTfulAPI-Tests-Cache',
	#package : 'Superluminal-RESTfulAPI-Tests',
	#tag : 'Cache'
}

{ #category : 'initialization' }
LocalMemoryCacheRepositoryTest >> setUpRepository [

	repository := LocalMemoryCacheRepository using: currentTimeProvider
]

{ #category : 'private' }
LocalMemoryCacheRepositoryTest >> waitFor: aDuration [

	currentDateTime := currentDateTime + aDuration
]
