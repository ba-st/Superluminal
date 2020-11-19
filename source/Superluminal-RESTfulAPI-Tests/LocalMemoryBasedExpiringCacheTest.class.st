Class {
	#name : #LocalMemoryBasedExpiringCacheTest,
	#superclass : #ExpiringCacheTest,
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #'as yet unclassified' }
LocalMemoryBasedExpiringCacheTest >> setUpExpiringCache [

	cache := ExpiringCache persistingTo: ( LocalMemoryCacheRepository using: dateTimeProvider )
]

{ #category : #'as yet unclassified' }
LocalMemoryBasedExpiringCacheTest >> waitFor: aDuration [ 
	
	currentDateTime := currentDateTime + aDuration

]
