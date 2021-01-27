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

{ #category : #private }
ExpiringResource >> date [

	^ ZnUtils parseHttpDate: ( response headers at: 'Date' )
]

{ #category : #private }
ExpiringResource >> expires [

	^ ZnUtils parseHttpDate: ( response headers at: 'Expires' )
]

{ #category : #private }
ExpiringResource >> ifMaxAgePresentDo: maxAgeBlock ifExpiresPresentDo: expiresBlock ifNone: noneBlock [

	"Max age represents the amount of time a resource is considered fresh. Unlike Expires, this directive is relative to the time of the request.
	
	Expires is an absolute datetime after which the response is considered stale."

	^ [ self
		withMaxAgeDo: [ :maxAge | maxAgeBlock value: self date + maxAge ]
		ifNone: [ expiresBlock value: self expires ]
	]
		on: NotFound , SubscriptOutOfBounds
		do: [ :ex | ex return: noneBlock value ]
]

{ #category : #initialization }
ExpiringResource >> initializeFor: aResource controlledBy: aResponse [

	currentResource := aResource.
	response := aResponse
]

{ #category : #testing }
ExpiringResource >> isExpiredAt: aPointInTime [

	^ self withExpirationDo: [ :expiration | expiration < aPointInTime ] ifNone: [ true ]
]

{ #category : #expiring }
ExpiringResource >> timeToExpireAt: aPointInTime [

	^ [ self
		withExpirationDo: [ :expiration | expiration - aPointInTime ]
		ifNone: [ ResourceHasExpired signal ]
	] unless: ( self isExpiredAt: aPointInTime ) inWhichCase: [ ResourceHasExpired signal ]
]

{ #category : #private }
ExpiringResource >> withExpirationDo: ifPresentBlock ifNone: noneBlock [

	^ self
		ifMaxAgePresentDo: ifPresentBlock 
		ifExpiresPresentDo: ifPresentBlock
		ifNone: noneBlock
]

{ #category : #private }
ExpiringResource >> withMaxAgeDo: ifPresentBlock ifNone: noneBlock [

	^ response cachingDirectives
		detect: [ :directive | directive asLowercase beginsWith: 'Max-Age' asLowercase ]
		ifFound: [ :string | 
			| maxAge |

			maxAge := ( string copyAfter: $= ) asNumber seconds.
			ifPresentBlock value: maxAge
			]
		ifNone: noneBlock
]
