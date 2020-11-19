"
An ExpiringCacheTest is a test class for testing the behavior of ExpiringCache
"
Class {
	#name : #ExpiringCacheTest,
	#superclass : #TestCase,
	#instVars : [
		'dateTime',
		'dateTimeProvider',
		'currentDateTime',
		'cache'
	],
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #testing }
ExpiringCacheTest class >> isAbstract [ 

	^  self name = #ExpiringCacheTest
]

{ #category : #private }
ExpiringCacheTest >> in: aResource obtain: answer cachedFor: aDuration [

	^ cache
		withResourceAt: aResource asUrl asString
		obtainedUsing: [ self resourceFor: answer expiringIn: aDuration ]
		do: [ :resource | 'Obtained <1s>' expandMacrosWith: resource ]
]

{ #category : #private }
ExpiringCacheTest >> obtain: answer cachedFor: aDuration [

	^ self in: 'here' obtain: answer cachedFor: aDuration
]

{ #category : #private }
ExpiringCacheTest >> resourceFor: answer expiringIn: aDuration [

	| headers response |

	headers := Dictionary new
		at: 'Date' put: ( ZnUtils httpDate: dateTime );
		at: 'Cache-Control' put: ( Array with: ( 'Max-Age=<1p>' expandMacrosWith: aDuration asSeconds ) );
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
	dateTimeProvider := [ currentDateTime ].
	self setUpExpiringCache
]

{ #category : #initialization }
ExpiringCacheTest >> setUpExpiringCache [

	self subclassResponsibility 
]

{ #category : #tests }
ExpiringCacheTest >> testCachedAnswerIsReturnedBeforeExpiration [

	| answer |

	answer := 'the first answer'.
	self assert: ( self obtain: answer cachedFor: 2 seconds ) equals: 'Obtained the first answer'.
	answer := 'an updated answer'.
	self assert: ( self obtain: answer cachedFor: 2 seconds ) equals: 'Obtained the first answer'.
	self waitFor: 1 second.
	self assert: ( self obtain: answer cachedFor: 2 seconds ) equals: 'Obtained the first answer'.
	self waitFor: 1.1 seconds.
	self assert: ( self obtain: answer cachedFor: 2 seconds ) equals: 'Obtained an updated answer'	
]

{ #category : #tests }
ExpiringCacheTest >> testClearResourceAt [

	| answer |

	answer := 'the first answer'.
	self assert: ( self obtain: answer cachedFor: 2 seconds ) equals: 'Obtained the first answer'.
	answer := 'an updated answer'.
	self assert: ( self obtain: answer cachedFor: 2 seconds ) equals: 'Obtained the first answer'.
	cache clearResourceAt: 'here'.
	self assert: ( self obtain: answer cachedFor: 2 seconds ) equals: 'Obtained an updated answer'
]

{ #category : #tests }
ExpiringCacheTest >> waitFor: aDuration [

	self subclassResponsibility 
]
