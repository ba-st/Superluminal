Class {
	#name : 'ExpiringResource',
	#superclass : 'Object',
	#instVars : [
		'currentResource',
		'response'
	],
	#category : 'Superluminal-RESTfulAPI-Cache',
	#package : 'Superluminal-RESTfulAPI',
	#tag : 'Cache'
}

{ #category : 'instance creation' }
ExpiringResource class >> for: aResource controlledBy: aResponse [

	^ self new initializeFor: aResource controlledBy: aResponse
]

{ #category : 'testing' }
ExpiringResource >> canBeStored [

	^ response canBeStoredInCache
]

{ #category : 'accessing' }
ExpiringResource >> contents [

	^ currentResource
]

{ #category : 'private' }
ExpiringResource >> date [

	^ ZnUtils parseHttpDate: ( response headers at: 'Date' )
]

{ #category : 'private' }
ExpiringResource >> expirationDateApplyingCacheControlDirectivesIfNone: noneBlock [

	| expirationDates |

	expirationDates := OrderedCollection new.

	response cachingDirectives do: [ :directive |
		| lowercasedDirective |

		lowercasedDirective := directive asLowercase.
		self if: lowercasedDirective isMaxAgeDirectiveApplyTo: expirationDates.
		self if: lowercasedDirective isNoCacheDirectiveApplyTo: expirationDates
		].

	^ expirationDates minUsing: [ :date | date ] ifEmpty: noneBlock
]

{ #category : 'private' }
ExpiringResource >> expires [

	^ ZnUtils parseHttpDate: ( response headers at: 'Expires' )
]

{ #category : 'private' }
ExpiringResource >> if: directive isMaxAgeDirectiveApplyTo: expirationDates [

	( directive beginsWith: 'max-age' ) then: [
		| maxAge |

		maxAge := ( directive copyAfter: $= ) asNumber seconds.
		expirationDates add: self date + maxAge
		]
]

{ #category : 'private' }
ExpiringResource >> if: directive isNoCacheDirectiveApplyTo: expirationDates [
	"The `no-cache` response directive indicates that the response can be stored in caches,
	but the response must be validated with the origin server before each reuse, even when
	the cache is disconnected from the origin server.

	If you want caches to always check for content updates while reusing stored content, `no-cache`
	is the directive to use. It does this by requiring caches to revalidate each request with the origin server.

	Note that `no-cache` does not mean `don't cache`. `no-cache` allows caches to store a response but requires them
	to revalidate it before reuse. If the sense of `don't cache` that you want is actually `don't store`, then
	`no-store` is the directive to use."

	directive = 'no-cache' then: [ expirationDates add: self date ]
]

{ #category : 'initialization' }
ExpiringResource >> initializeFor: aResource controlledBy: aResponse [

	currentResource := aResource.
	response := aResponse
]

{ #category : 'testing' }
ExpiringResource >> isExpiredAt: aPointInTime [

	^ self withExpirationDo: [ :expiration | expiration <= aPointInTime ] ifNone: [ true ]
]

{ #category : 'private' }
ExpiringResource >> withExpirationDo: ifPresentBlock ifNone: noneBlock [

	^ [
	  ifPresentBlock value:
		  ( self expirationDateApplyingCacheControlDirectivesIfNone: [ self expires ] ) ]
		  on: NotFound , SubscriptOutOfBounds , CollectionIsEmpty
		  do: [ :ex | ex return: noneBlock value ]
]

{ #category : 'expiring' }
ExpiringResource >> withTimeToExpireAt: aPointInTime do: aBlock [

	self
		withExpirationDo: [ :expiration | 
			| timeToExpire |

			timeToExpire := expiration - aPointInTime.
			timeToExpire > 0 seconds then: [ aBlock value: timeToExpire ]
			]
		ifNone: [  ]
]
