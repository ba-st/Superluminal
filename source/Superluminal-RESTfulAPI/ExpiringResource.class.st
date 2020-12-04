Class {
	#name : #ExpiringResource,
	#superclass : #Object,
	#instVars : [
		'currentResource',
		'response'
	],
	#category : #'Superluminal-RESTfulAPI'
}

{ #category : #'instance creation' }
ExpiringResource class >> for: aResource controlledBy: aResponse [

	^ self new initializeFor: aResource controlledBy: aResponse
]

{ #category : #accessing }
ExpiringResource >> contents [

	^currentResource
]

{ #category : #initialization }
ExpiringResource >> initializeFor: aResource controlledBy: aResponse [

	currentResource := aResource.
	response := aResponse
]

{ #category : #testing }
ExpiringResource >> isExpiredAt: aPointInTime [

	^ response cachingDirectives
		detect: [ :directive | directive asLowercase beginsWith: 'Max-Age' asLowercase ]
		ifFound: [ :string | 
			| maxAge |
			maxAge := ( string copyAfter: $= ) asNumber.
			self isExpiredUsing: 'Date' after: maxAge secondsAt: aPointInTime
			]
		ifNone: [ self isExpiredUsing: 'Expires' after: 0 secondsAt: aPointInTime ]
]

{ #category : #'private - testing' }
ExpiringResource >> isExpiredUsing: aKey after: aNumber secondsAt: aPointInTime [

	"Any error when parsing expiredKed header should be considered as expired. See: https://tools.ietf.org/html/rfc7234#section-5.3 "

	| date expiration expiredValue |
	expiredValue := response headers at: aKey ifAbsent: [ ^ true ].
	^ [ date := ZnUtils parseHttpDate: expiredValue.
	expiration := date + aNumber seconds.
	expiration < aPointInTime truncated ]
		on: Error
		do: [ :ex | ex return: true ]
]
