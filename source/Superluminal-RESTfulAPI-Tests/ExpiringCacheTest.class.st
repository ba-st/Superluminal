"
An ExpiringCacheTest is a test class for testing the behavior of ExpiringCache
"
Class {
	#name : #ExpiringCacheTest,
	#superclass : #TestCase,
	#instVars : [
		'dateTime',
		'dateTimeProvider',
		'currentDateTime'
	],
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #private }
ExpiringCacheTest >> in: aResource obtain: answer from: cache [

	^cache
		withResourceAt: aResource asUrl asString
		obtainedUsing: [(self resourceFor: answer)]
		do: [:resource | 'Obtained <1s>' expandMacrosWith: resource]
]

{ #category : #private }
ExpiringCacheTest >> obtain: answer from: cache [

	^self in: 'here' obtain: answer from: cache
]

{ #category : #private }
ExpiringCacheTest >> resourceFor: answer [

	| headers response |

	headers := Dictionary new
		at: 'Date' put: ( ZnUtils httpDate: dateTime );
		at: 'Cache-Control' put: #('Max-Age=60');
		yourself.
	response := ZnResponse noContent
		headers: headers;
		yourself.
	^ ExpiringResource for: answer controlledBy: response
]

{ #category : #running }
ExpiringCacheTest >> setUp [

	super setUp.
	dateTime := DateAndTime now.
	currentDateTime := dateTime.
	dateTimeProvider := [ currentDateTime ]
]

{ #category : #tests }
ExpiringCacheTest >> testCachedAnswerIsReturnedBeforeExpiration [

	| cache answer |

	cache := ExpiringCache accordingTo: dateTimeProvider.
	answer := 'the first answer'.
	self assert: ( self obtain: answer from: cache ) equals: 'Obtained the first answer'.
	answer := 'an updated answer'.
	self assert: ( self obtain: answer from: cache ) equals: 'Obtained the first answer'.
	currentDateTime := dateTime + 1 minute.
	self assert: ( self obtain: answer from: cache ) equals: 'Obtained the first answer'.
	currentDateTime := dateTime + 2 minutes.
	self assert: ( self obtain: answer from: cache ) equals: 'Obtained an updated answer'
]

{ #category : #tests }
ExpiringCacheTest >> testClearResourceAt [

	| cache answer |

	cache := ExpiringCache accordingTo: dateTimeProvider.
	answer := 'the first answer'.
	self assert: ( self obtain: answer from: cache ) equals: 'Obtained the first answer'.
	answer := 'an updated answer'.
	self assert: ( self obtain: answer from: cache ) equals: 'Obtained the first answer'.
	cache clearResourceAt: 'here'.
	self assert: ( self obtain: answer from: cache ) equals: 'Obtained an updated answer'
]

{ #category : #tests }
ExpiringCacheTest >> testClearSubResources [

	| cache answer answerForSubresource |

	cache := ExpiringCache accordingTo: dateTimeProvider.
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
