"
An ExpiringCacheTest is a test class for testing the behavior of ExpiringCache
"
Class {
	#name : #ExpiringCacheTest,
	#superclass : #TestCase,
	#instVars : [
		'currentDateTime',
		'cache',
		'location',
		'currentTimeProvider'
	],
	#category : #'Superluminal-RESTfulAPI-Tests-Cache'
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

	^ self in: location obtain: answer cachedFor: aDuration
]

{ #category : #private }
ExpiringCacheTest >> resourceFor: answer expiringIn: aDuration [

	| response |

	response := ZnResponse noContent.
	response headers at: 'Date' put: ( ZnUtils httpDate: currentDateTime ).
	response addCachingDirective: ( 'Max-Age=<1p>' expandMacrosWith: aDuration asSeconds ).
	^ ExpiringResource for: answer controlledBy: response
]

{ #category : #running }
ExpiringCacheTest >> setUp [

	super setUp.
	currentDateTime := DateAndTime now truncated.
	currentTimeProvider := [ currentDateTime ].
	location := 'answers' asUrl / UUID new asString.
	self setUpExpiringCache
]

{ #category : #running }
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
	self waitFor: 1 seconds + 1 milliSecond.
	self assert: ( self obtain: answer cachedFor: 2 seconds ) equals: 'Obtained an updated answer'	
]

{ #category : #tests }
ExpiringCacheTest >> testClearResourceAt [

	| answer |

	answer := 'the first answer'.
	self assert: ( self obtain: answer cachedFor: 2 seconds ) equals: 'Obtained the first answer'.
	answer := 'an updated answer'.
	self assert: ( self obtain: answer cachedFor: 2 seconds ) equals: 'Obtained the first answer'.
	cache clearResourceAt: location.
	self assert: ( self obtain: answer cachedFor: 2 seconds ) equals: 'Obtained an updated answer'
]

{ #category : #private }
ExpiringCacheTest >> waitFor: aDuration [

	self subclassResponsibility 
]
