Class {
	#name : #LocalMemoryBasedExpiringCacheTest,
	#superclass : #ExpiringCacheTest,
	#category : #'Superluminal-RESTfulAPI-Tests-Cache'
}

{ #category : #running }
LocalMemoryBasedExpiringCacheTest >> setUpExpiringCache [

	cache := ExpiringCache persistingTo: ( LocalMemoryCacheRepository using: currentTimeProvider )
]

{ #category : #private }
LocalMemoryBasedExpiringCacheTest >> waitFor: aDuration [ 
	
	currentDateTime := currentDateTime + aDuration

]
