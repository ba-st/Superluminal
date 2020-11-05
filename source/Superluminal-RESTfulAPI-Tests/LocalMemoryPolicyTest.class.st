Class {
	#name : #LocalMemoryPolicyTest,
	#superclass : #TestCase,
	#instVars : [
		'dateTimeProvider',
		'dateTime',
		'currentDateTime'
	],
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #'as yet unclassified' }
LocalMemoryPolicyTest >> resourceFor: answer [

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
LocalMemoryPolicyTest >> setUp [

	super setUp.
	dateTime := DateAndTime now.
	currentDateTime := dateTime.
	dateTimeProvider := [ currentDateTime ]
]

{ #category : #tests }
LocalMemoryPolicyTest >> testExpiring [
	
	| policy answer resource |
	
	policy := LocalMemoryPolicy accordingTo: dateTimeProvider.
	answer := 'the first answer'.
	resource := self resourceFor: answer.
	policy
		store: resource
		at: 'key'.	
	self assert: (policy get: 'key') contents equals: answer.
	
	currentDateTime := dateTime + 3 second.	
	
	self assert: (policy get: 'key') isNil
]

{ #category : #tests }
LocalMemoryPolicyTest >> testSet [

	| policy answer |

	policy := LocalMemoryPolicy accordingTo: dateTimeProvider.
	answer := 'the first answer'.
	policy store: (self resourceFor: answer) at: 'key'.
	self assert: (policy get: 'key') contents equals: answer
]
