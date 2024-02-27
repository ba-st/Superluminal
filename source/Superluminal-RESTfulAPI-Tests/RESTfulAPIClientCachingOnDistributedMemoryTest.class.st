Class {
	#name : 'RESTfulAPIClientCachingOnDistributedMemoryTest',
	#superclass : 'RESTfulAPIClientTest',
	#category : 'Superluminal-RESTfulAPI-Tests',
	#package : 'Superluminal-RESTfulAPI-Tests'
}

{ #category : 'accessing' }
RESTfulAPIClientCachingOnDistributedMemoryTest >> apiClient [

	^ RESTfulAPIClient
		  buildingHttpClientWith: [ self httpClient ]
		  cachingIn: (ExpiringCache onDistributedMemoryAt:
				   { ('<1s>:11211' expandMacrosWith: self memcachedHostname) })
]
