Class {
	#name : 'CacheRepositoryTest',
	#superclass : 'SuperluminalTest',
	#instVars : [
		'currentDateTime',
		'repository',
		'currentTimeProvider'
	],
	#category : 'Superluminal-RESTfulAPI-Tests-Cache',
	#package : 'Superluminal-RESTfulAPI-Tests',
	#tag : 'Cache'
}

{ #category : 'testing' }
CacheRepositoryTest class >> isAbstract [ 

	^  self name = #CacheRepositoryTest
]

{ #category : 'private' }
CacheRepositoryTest >> resourceFor: answer expiringIn: aDuration [

	| headers response |

	headers := Dictionary new
		at: 'Date' put: ( ZnUtils httpDate: currentDateTime );
		at: 'Cache-Control' put: ( Array with: ( 'Max-Age=<1p>' expandMacrosWith: aDuration asSeconds ) );
		yourself.
	response := ZnResponse noContent
		headers: headers;
		yourself.
	^ ExpiringResource for: answer controlledBy: response
]

{ #category : 'running' }
CacheRepositoryTest >> setUp [

	super setUp.
	currentDateTime := DateAndTime now rounded.
	currentTimeProvider := [ currentDateTime ].
	self setUpRepository
]

{ #category : 'running' }
CacheRepositoryTest >> setUpRepository [

	self subclassResponsibility 
]

{ #category : 'tests' }
CacheRepositoryTest >> testExpiring [

	| answer resource |

	answer := 'the first answer'.
	resource := self resourceFor: answer expiringIn: 2 seconds.
	repository store: resource at: 'key'.
	self assert: ( repository get: 'key' ) contents equals: answer.
	self waitFor: 2.1 seconds.
	self should: [ repository get: 'key' ] raise: KeyNotFound withMessageText: '''key'' not found'
]

{ #category : 'tests' }
CacheRepositoryTest >> testGetKeyIfAbsent [

	self
		should: [ repository get: 'absent_key' ]
		raise: KeyNotFound
		withMessageText: '''absent_key'' not found'
]

{ #category : 'tests' }
CacheRepositoryTest >> testRemove [

	| answer |

	answer := 'the first answer'.
	repository store: ( self resourceFor: answer expiringIn: 2 seconds ) at: 'key'.
	self assert: ( repository get: 'key' ) contents equals: answer.
	repository remove: 'key'.
	self should: [ repository get: 'key' ] raise: KeyNotFound withMessageText: '''key'' not found'
]

{ #category : 'tests' }
CacheRepositoryTest >> testRemoveAbsentKey [ 

	self shouldnt: [ repository remove: 'absent_key' ] raise: KeyNotFound
]

{ #category : 'tests' }
CacheRepositoryTest >> testStoreAt [

	| answer |

	answer := 'the first answer'.
	repository store: ( self resourceFor: answer expiringIn: 2 seconds ) at: 'key'.
	self assert: ( repository get: 'key' ) contents equals: answer
]

{ #category : 'running' }
CacheRepositoryTest >> waitFor: aDuration [

	self subclassResponsibility 
]
