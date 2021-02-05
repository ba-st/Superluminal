"
An ExpiringResourceTest is a test class for testing the behavior of ExpiringResource
"
Class {
	#name : #ExpiringResourceTest,
	#superclass : #TestCase,
	#instVars : [
		'currentDateTime'
	],
	#category : #'Superluminal-RESTfulAPI-Tests-Cache'
}

{ #category : #'tests - support' }
ExpiringResourceTest >> assert: anExpiringResource expiresIn: aDuration at: aPointInTime [

	anExpiringResource
		withTimeToExpireAt: aPointInTime
		do: [ :timeToExpire | self assert: timeToExpire equals: aDuration ]
]

{ #category : #'tests - support' }
ExpiringResourceTest >> assert: anExpiringResource hasExpiredAt: aPointInTime [

	anExpiringResource withTimeToExpireAt: aPointInTime do: [ :timeToExpire | self fail ]
]

{ #category : #'tests - support' }
ExpiringResourceTest >> resourceOriginatedAt: dateTime expiresContaining: expires [

	| response headers |

	headers := Dictionary new
		at: 'Date' put: ( ZnUtils httpDate: dateTime );
		at: 'Expires' put: expires;
		yourself.
	response := ZnResponse noContent
		headers: headers;
		yourself.
	^ ExpiringResource for: 'here' controlledBy: response
]

{ #category : #'tests - support' }
ExpiringResourceTest >> resourceOriginatedAt: dateTime expiringAt: expiringDateTime [

	| expires |

	expires := ZnUtils httpDate: expiringDateTime.
	^ self resourceOriginatedAt: dateTime expiresContaining: expires
]

{ #category : #'tests - support' }
ExpiringResourceTest >> resourceOriginatedAt: dateTime expiringIn: aDuration [

	| response headers maxAge |

	maxAge := 'Max-Age=<1p>' expandMacrosWith: aDuration totalSeconds.
	headers := Dictionary new
		at: 'Date' put: ( ZnUtils httpDate: dateTime );
		at: 'Cache-Control' put: {maxAge};
		yourself.
	response := ZnResponse noContent
		headers: headers;
		yourself.
	^ ExpiringResource for: 'here' controlledBy: response
]

{ #category : #running }
ExpiringResourceTest >> setUp [
	
	currentDateTime := DateAndTime now truncated
]

{ #category : #tests }
ExpiringResourceTest >> testExpiredWhenExpiresSetToInvalidDate [

	"A cache recipient MUST interpret invalid date formats, especially the
   value 0, as representing a time in the past (i.e., 'already
   expired').

	See: https://tools.ietf.org/html/rfc7234#section-5.3"

	| resource |

	resource := self resourceOriginatedAt: currentDateTime expiresContaining: 'not-a-date'.
	self
		assert: resource contents equals: 'here';
		assert: ( resource isExpiredAt: currentDateTime );
		assert: ( resource isExpiredAt: currentDateTime + 1 second );
		assert: ( resource isExpiredAt: currentDateTime - 1 second ).
	resource := self resourceOriginatedAt: currentDateTime expiresContaining: '0'.
	self
		assert: resource contents equals: 'here';
		assert: ( resource isExpiredAt: currentDateTime );
		assert: ( resource isExpiredAt: currentDateTime + 1 second );
		assert: ( resource isExpiredAt: currentDateTime - 1 second )
]

{ #category : #tests }
ExpiringResourceTest >> testIsExpiredAtUsingExpires [

	| resource |

	resource := self
		resourceOriginatedAt: currentDateTime
		expiringAt: currentDateTime.
	self
		assert: resource contents equals: 'here';
		deny: ( resource isExpiredAt: currentDateTime );
		deny: ( resource isExpiredAt: currentDateTime - 1 second );
		assert: ( resource isExpiredAt: currentDateTime + 1 second ).

	resource := self
		resourceOriginatedAt: currentDateTime
		expiringAt: currentDateTime + 55 seconds.
	self
		assert: resource contents equals: 'here';
		deny: ( resource isExpiredAt: currentDateTime );
		deny: ( resource isExpiredAt: currentDateTime - 1 second );
		deny: ( resource isExpiredAt: currentDateTime + 1 second );
		deny: ( resource isExpiredAt: currentDateTime + 55 seconds );
		assert: ( resource isExpiredAt: currentDateTime + 56 seconds )
]

{ #category : #tests }
ExpiringResourceTest >> testIsExpiredAtUsingMaxAge [

	| resource |

	resource := self resourceOriginatedAt: currentDateTime expiringIn: 0 seconds.
	self
		assert: resource contents equals: 'here';
		deny: ( resource isExpiredAt: currentDateTime );
		deny: ( resource isExpiredAt: currentDateTime - 1 second );
		assert: ( resource isExpiredAt: currentDateTime + 1 second ).

	resource := self resourceOriginatedAt: currentDateTime expiringIn: 55 seconds.
	self
		assert: resource contents equals: 'here';
		deny: ( resource isExpiredAt: currentDateTime );
		deny: ( resource isExpiredAt: currentDateTime - 1 second );
		deny: ( resource isExpiredAt: currentDateTime + 1 second );
		deny: ( resource isExpiredAt: currentDateTime + 55 seconds );
		assert: ( resource isExpiredAt: currentDateTime + 56 seconds )
]

{ #category : #tests }
ExpiringResourceTest >> testIsExpiredAtWithoutCacheDirectives [

	| headers resource response |

	headers := Dictionary new
		at: 'Date' put: ( ZnUtils httpDate: currentDateTime );
		yourself.
	response := ZnResponse noContent
		headers: headers;
		yourself.
	resource := ExpiringResource for: 'here' controlledBy: response.
	self
		assert: resource contents equals: 'here';
		assert: ( resource isExpiredAt: currentDateTime );
		assert: ( resource isExpiredAt: currentDateTime + 1 second );
		assert: ( resource isExpiredAt: currentDateTime + 1 minute );
		assert: ( resource isExpiredAt: currentDateTime + 1 hour )
]

{ #category : #tests }
ExpiringResourceTest >> testWithTimeToExpireAtDoUsingExpires [

	| resource |

	resource := self resourceOriginatedAt: currentDateTime expiringAt: currentDateTime.

	self
		assert: resource contents equals: 'here';
		assert: resource hasExpiredAt: currentDateTime;
		assert: resource hasExpiredAt: currentDateTime + 1 second;
		assert: resource expiresIn: 1 second at: currentDateTime - 1 second.

	resource := self resourceOriginatedAt: currentDateTime expiringAt: currentDateTime + 55 seconds.

	self
		assert: resource contents equals: 'here';
		assert: resource expiresIn: 55 seconds at: currentDateTime;
		assert: resource expiresIn: 56 seconds at: currentDateTime - 1 second;
		assert: resource expiresIn: 54 seconds at: currentDateTime + 1 second;
		assert: resource hasExpiredAt: currentDateTime + 1 minute
]

{ #category : #tests }
ExpiringResourceTest >> testWithTimeToExpireAtDoUsingMaxAge [

	| resource |

	resource := self resourceOriginatedAt: currentDateTime expiringIn: 0 seconds.
	self
		assert: resource contents equals: 'here';
		assert: resource hasExpiredAt: currentDateTime;
		assert: resource hasExpiredAt: currentDateTime + 1 second;
		assert: resource expiresIn: 1 second at: currentDateTime - 1 second.

	resource := self resourceOriginatedAt: currentDateTime expiringIn: 55 seconds.

	self
		assert: resource contents equals: 'here';
		assert: resource expiresIn: 55 seconds at: currentDateTime;
		assert: resource expiresIn: 56 seconds at: currentDateTime - 1 second;
		assert: resource expiresIn: 54 seconds at: currentDateTime + 1 second;
		assert: resource hasExpiredAt: currentDateTime + 1 minute
]
