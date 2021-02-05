Class {
	#name : #RESTfulAPIClientCachingOnLocalMemoryTest,
	#superclass : #RESTfulAPIClientTest,
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #running }
RESTfulAPIClientCachingOnLocalMemoryTest >> apiClient [

	^ RESTfulAPIClient
		buildingHttpClientWith: [ self httpClient ]
		cachingIn: ExpiringCache onLocalMemory
]
