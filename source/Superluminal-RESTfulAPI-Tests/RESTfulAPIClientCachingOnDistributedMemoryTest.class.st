Class {
	#name : 'RESTfulAPIClientCachingOnDistributedMemoryTest',
	#superclass : 'RESTfulAPIClientTest',
	#category : 'Superluminal-RESTfulAPI-Tests',
	#package : 'Superluminal-RESTfulAPI-Tests'
}

{ #category : 'running' }
RESTfulAPIClientCachingOnDistributedMemoryTest >> apiClient [

	^ RESTfulAPIClient
		buildingHttpClientWith: [ self httpClient ]
		cachingIn: ( ExpiringCache onDistributedMemoryAt: {'127.0.0.1:11211'} )
]
