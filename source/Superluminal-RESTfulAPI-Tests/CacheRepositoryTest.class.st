Class {
	#name : #CacheRepositoryTest,
	#superclass : #TestCase,
	#instVars : [
		'dateTime',
		'currentDateTime',
		'dateTimeProvider',
		'repository'
	],
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #testing }
CacheRepositoryTest class >> isAbstract [ 

	^  self name = #CacheRepositoryTest
]

{ #category : #'as yet unclassified' }
CacheRepositoryTest >> resourceFor: answer expiringIn: aDuration [

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
CacheRepositoryTest >> setUp [

	super setUp.
	dateTime := DateAndTime now.
	currentDateTime := dateTime.
	dateTimeProvider := [ currentDateTime ].
	self setUpRepository
]

{ #category : #initialization }
CacheRepositoryTest >> setUpRepository [

	self subclassResponsibility 
]

{ #category : #tests }
CacheRepositoryTest >> testExpiring [

	| answer resource |

	answer := 'the first answer'.
	resource := self resourceFor: answer expiringIn: 2 seconds.
	repository store: resource at: 'key'.
	self assert: ( repository get: 'key' ) contents equals: answer.
	self waitFor: 2.1 seconds.
	self should: [ repository get: 'key' ] raise: KeyNotFound
]

{ #category : #tests }
CacheRepositoryTest >> testGetKeyIfAbsent [ 

	self should: [ repository get: 'absent_key' ] raise: KeyNotFound
]

{ #category : #tests }
CacheRepositoryTest >> testRemove [

	| answer |

	answer := 'the first answer'.
	repository store: ( self resourceFor: answer expiringIn: 2 seconds ) at: 'key'.
	self assert: ( repository get: 'key' ) contents equals: answer.
	repository remove: 'key'.
	self should: [ repository get: 'key' ] raise: KeyNotFound 
]

{ #category : #tests }
CacheRepositoryTest >> testRemoveKeyIfAbsent [ 

	self shouldnt: [ repository remove: 'key' ] raise: KeyNotFound
]

{ #category : #tests }
CacheRepositoryTest >> testSet [

	| answer |

	answer := 'the first answer'.
	repository store: ( self resourceFor: answer expiringIn: 2 seconds ) at: 'key'.
	self assert: ( repository get: 'key' ) contents equals: answer
]
