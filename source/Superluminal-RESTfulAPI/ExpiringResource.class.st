Class {
	#name : #ExpiringResource,
	#superclass : #Object,
	#instVars : [
		'currentResource',
		'response'
	],
	#category : #'Superluminal-RESTfulAPI-Cache'
}

{ #category : #'instance creation' }
ExpiringResource class >> for: aResource controlledBy: aResponse [

	^ self new initializeFor: aResource controlledBy: aResponse
]

{ #category : #accessing }
ExpiringResource >> contents [

	^ currentResource
]

{ #category : #expiration }
ExpiringResource >> expiresIn: aPointInTime [

	^ self
		withMaxAgeDo: [ :maxAge | self expiresInUsing: 'Date' after: maxAge secondsAt: aPointInTime ]
		ifNone: [ self expiresInUsing: 'Expires' after: 0 secondsAt: aPointInTime ]
]

{ #category : #private }
ExpiringResource >> expiresInUsing: aKey after: aNumber secondsAt: aPointInTime [

	| date expiration |

	date := ZnUtils parseHttpDate: ( response headers at: aKey ifAbsent: [ ^ self halt ] ).
	expiration := date + aNumber seconds.
	^ expiration - aPointInTime truncated
]

{ #category : #initialization }
ExpiringResource >> initializeFor: aResource controlledBy: aResponse [

	currentResource := aResource.
	response := aResponse
]

{ #category : #testing }
ExpiringResource >> isExpiredAt: aPointInTime [

	^ self
		withMaxAgeDo: [ :maxAge | self isExpiredUsing: 'Date' after: maxAge secondsAt: aPointInTime ]
		ifNone: [ self isExpiredUsing: 'Expires' after: 0 secondsAt: aPointInTime ]
]

{ #category : #private }
ExpiringResource >> isExpiredUsing: aKey after: aNumber secondsAt: aPointInTime [

	| date expiration |

	date := ZnUtils parseHttpDate: ( response headers at: aKey ifAbsent: [ ^ true ] ).
	expiration := date + aNumber seconds.
	^ expiration < aPointInTime truncated
]

{ #category : #private }
ExpiringResource >> withMaxAgeDo: ifPresentBlock ifNone: ifNoneBlock [

	^ response cachingDirectives
		detect: [ :directive | directive asLowercase beginsWith: 'Max-Age' asLowercase ]
		ifFound: [ :string | 
			| maxAge |

			maxAge := ( string copyAfter: $= ) asNumber.
			ifPresentBlock value: maxAge
			]
		ifNone: ifNoneBlock
]
