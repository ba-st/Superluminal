Class {
	#name : #DistributedMemoryPolicyTest,
	#superclass : #TestCase,
	#instVars : [
		'dateTimeProvider',
		'dateTime',
		'currentDateTime',
		'memcached'
	],
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #'as yet unclassified' }
DistributedMemoryPolicyTest >> resourceFor: answer [

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
DistributedMemoryPolicyTest >> setUp [

	super setUp.
	dateTime := DateAndTime now.
	currentDateTime := dateTime.
	dateTimeProvider := [ currentDateTime ].
	memcached := MDCacheClient onServers: {'127.0.0.1:11211'}
]

{ #category : #tests }
DistributedMemoryPolicyTest >> testExpiring [
	
	| cache answer resource |
	
	cache := DistributedMemoryPolicy accordingTo: dateTimeProvider storingOn: memcached.
	answer := 'the first answer'.
	resource := self resourceFor: answer.
	cache
		store: resource
		at: 'key'.	
	self assert: (cache get: 'key') contents equals: answer.
	
	currentDateTime := dateTime + 3 second.	
	
	self assert: (cache get: 'key') isNil
]

{ #category : #tests }
DistributedMemoryPolicyTest >> testSet [

	| policy answer |

	policy := DistributedMemoryPolicy accordingTo: dateTimeProvider storingOn: memcached.
	answer := 'the first answer'.
	policy store: (self resourceFor: answer) at: 'key'.
	self assert: (policy get: 'key') contents equals: answer.
]
