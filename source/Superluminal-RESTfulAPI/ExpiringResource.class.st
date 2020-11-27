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

	| date expiration |

	date := ZnUtils parseHttpDate: (response headers at: aKey ifAbsent: [^true]).
	expiration := date + aNumber seconds.
	^expiration < aPointInTime truncated
]
