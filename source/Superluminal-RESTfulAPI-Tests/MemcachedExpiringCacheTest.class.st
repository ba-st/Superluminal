Class {
	#name : #MemcachedExpiringCacheTest,
	#superclass : #TestCase,
	#instVars : [
		'dateTime',
		'currentDateTime',
		'dateTimeProvider',
		'memcached'
	],
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #private }
MemcachedExpiringCacheTest >> in: aResource obtain: answer from: cache [

	^cache
		withResourceAt: aResource asUrl asString
		obtainedUsing: [(self resourceFor: answer)]
		do: [:resource | 'Obtained <1s>' expandMacrosWith: resource]
]

{ #category : #private }
MemcachedExpiringCacheTest >> obtain: answer from: cache [

	^self in: 'here' obtain: answer from: cache
]

{ #category : #private }
MemcachedExpiringCacheTest >> resourceFor: answer [

	| headers response |

	headers := Dictionary new
		at: 'Date' put: ( ZnUtils httpDate: dateTime );
		at: 'Cache-Control' put: #('Max-Age=2');
		yourself.
	response := ZnResponse noContent
		headers: headers;
		yourself.
	^ ExpiringResource for: answer controlledBy: response
]

{ #category : #running }
MemcachedExpiringCacheTest >> setUp [

	super setUp.
	dateTime := DateAndTime now.
	currentDateTime := dateTime.
	dateTimeProvider := [ currentDateTime ].
	memcached := MDCacheClient onServers: {'127.0.0.1:11211'}
]

{ #category : #tests }
MemcachedExpiringCacheTest >> testCachedAnswerIsReturnedBeforeExpiration [

	| cache answer |

	cache := ExpiringMemcachedCache accordingTo: dateTimeProvider storingOn: memcached.
	answer := 'the first answer'.
	self assert: ( self obtain: answer from: cache ) equals: 'Obtained the first answer'.
	answer := 'an updated answer'.
	self assert: ( self obtain: answer from: cache ) equals: 'Obtained the first answer'.
	1 seconds asDelay wait.
	currentDateTime := dateTime + 1 second.	
	self assert: ( self obtain: answer from: cache ) equals: 'Obtained the first answer'.
	1 seconds asDelay wait.
	currentDateTime := dateTime + 1 second.
	self assert: ( self obtain: answer from: cache ) equals: 'Obtained an updated answer'.
	2 seconds asDelay wait.
	currentDateTime := dateTime + 2 second.
	self assert: ( memcached get: answer asUrl asString ) isNil
]

{ #category : #tests }
MemcachedExpiringCacheTest >> testClearResourceAt [

	| cache answer |

	cache := ExpiringMemcachedCache accordingTo: dateTimeProvider storingOn: memcached.
	answer := 'the first answer'.
	self assert: ( self obtain: answer from: cache ) equals: 'Obtained the first answer'.
	answer := 'an updated answer'.
	self assert: ( self obtain: answer from: cache ) equals: 'Obtained the first answer'.
	cache clearResourceAt: 'here'.
	self assert: ( self obtain: answer from: cache ) equals: 'Obtained an updated answer'
]

{ #category : #tests }
MemcachedExpiringCacheTest >> testClearSubResources [

	| cache answer answerForSubresource |

	cache := ExpiringMemcachedCache accordingTo: dateTimeProvider storingOn: memcached.
	answer := 'the first answer'.
	self assert: ( self in: 'here' obtain: answer from: cache ) equals: 'Obtained the first answer'.
	answerForSubresource := 'the first subresource answer'.
	self
		assert: ( self in: 'here/subresource' obtain: answerForSubresource from: cache )
		equals: 'Obtained the first subresource answer'.
	answer := 'an updated answer'.
	self assert: ( self in: 'here' obtain: answer from: cache ) equals: 'Obtained the first answer'.
	self
		assert: ( self in: 'here/subresource' obtain: answerForSubresource from: cache )
		equals: 'Obtained the first subresource answer'.
	cache clearResourceAt: 'here'.
	answerForSubresource := 'updated subresource answer'.
	self assert: ( self in: 'here' obtain: answer from: cache ) equals: 'Obtained an updated answer'.
	self
		assert: ( self in: 'here/subresource' obtain: answerForSubresource from: cache )
		equals: 'Obtained updated subresource answer'
]
