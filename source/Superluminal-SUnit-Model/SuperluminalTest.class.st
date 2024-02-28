Class {
	#name : 'SuperluminalTest',
	#superclass : 'TestCase',
	#category : 'Superluminal-SUnit-Model',
	#package : 'Superluminal-SUnit-Model'
}

{ #category : 'testing' }
SuperluminalTest class >> isAbstract [

	^ self = SuperluminalTest
]

{ #category : 'accessing' }
SuperluminalTest >> httpbinHostname [

	^ LanguagePlatform current os
		  environmentAt: 'CI_HTTPBIN_HOSTNAME'
		  ifPresent: [ :hostnameInVariable | hostnameInVariable ]
		  ifAbsent: [ 'localhost' ]
]

{ #category : 'accessing' }
SuperluminalTest >> memcachedHostname [

	^ LanguagePlatform current os
		  environmentAt: 'CI_MEMCACHED_HOSTNAME'
		  ifPresent: [ :hostnameInVariable | hostnameInVariable ]
		  ifAbsent: [ '127.0.0.1' ]
]
