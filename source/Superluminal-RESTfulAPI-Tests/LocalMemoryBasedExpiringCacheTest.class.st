Class {
	#name : #LocalMemoryBasedExpiringCacheTest,
	#superclass : #ExpiringCacheTest,
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #running }
LocalMemoryBasedExpiringCacheTest >> setUpExpiringCache [

	cache := ExpiringCache persistingTo: ( LocalMemoryCacheRepository using: dateTimeProvider )
]

{ #category : #private }
LocalMemoryBasedExpiringCacheTest >> waitFor: aDuration [ 
	
	currentDateTime := currentDateTime + aDuration

]
