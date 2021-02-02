Class {
	#name : #LocalMemoryCacheRepositoryTest,
	#superclass : #CacheRepositoryTest,
	#category : #'Superluminal-RESTfulAPI-Tests-Cache'
}

{ #category : #initialization }
LocalMemoryCacheRepositoryTest >> setUpRepository [

	repository := LocalMemoryCacheRepository using: currentTimeProvider
]

{ #category : #private }
LocalMemoryCacheRepositoryTest >> waitFor: aDuration [

	currentDateTime := currentDateTime + aDuration
]
