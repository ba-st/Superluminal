Class {
	#name : #LocalMemoryCacheRepositoryTest,
	#superclass : #CacheRepositoryTest,
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #initialization }
LocalMemoryCacheRepositoryTest >> setUpRepository [

	repository := LocalMemoryCacheRepository using: dateTimeProvider
]

{ #category : #'as yet unclassified' }
LocalMemoryCacheRepositoryTest >> waitFor: aDuration [

	currentDateTime := dateTime + aDuration
]
