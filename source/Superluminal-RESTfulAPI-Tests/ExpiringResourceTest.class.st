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
ExpiringResourceTest >> assertHasTheExpectedContents: resource [

	self assert: resource contents equals: 'here'
]

{ #category : #'tests - support' }
ExpiringResourceTest >> expiringResourceControlledBy: response [

	^ ExpiringResource for: 'here' controlledBy: response
]

{ #category : #'tests - support' }
ExpiringResourceTest >> resourceOriginatedAt: dateTime expiresContaining: expires [

	| response |

	response := self responseWithDateHeader: dateTime.
	response headers at: 'Expires' put: expires.
	^ self expiringResourceControlledBy: response
]

{ #category : #'tests - support' }
ExpiringResourceTest >> resourceOriginatedAt: dateTime expiringAt: expiringDateTime [

	| expires |

	expires := ZnUtils httpDate: expiringDateTime.
	^ self resourceOriginatedAt: dateTime expiresContaining: expires
]

{ #category : #'tests - support' }
ExpiringResourceTest >> resourceOriginatedAt: dateTime expiringIn: aDuration [

	| response |

	response := self responseWithDateHeader: dateTime.
	response addCachingDirective: ( 'Max-Age=<1p>' expandMacrosWith: aDuration totalSeconds ).
	^ self expiringResourceControlledBy: response
]

{ #category : #'tests - support' }
ExpiringResourceTest >> resourceWithNoCacheDirectiveOriginatedAt: dateTime [

	| response |

	response := self responseWithDateHeader: dateTime.
	response addCachingDirective: 'no-cache'.
	^ self expiringResourceControlledBy: response
]

{ #category : #'tests - support' }
ExpiringResourceTest >> resourceWithNoCacheDirectiveOriginatedAt: dateTime expiringIn: aDuration [

	| response |

	response := self responseWithDateHeader: dateTime.
	response
		addCachingDirective: ( 'Max-Age=<1p>' expandMacrosWith: aDuration totalSeconds );
		addCachingDirective: 'no-cache'.
	^ self expiringResourceControlledBy: response
]

{ #category : #'tests - support' }
ExpiringResourceTest >> responseWithDateHeader: dateTime [

	| response |

	response := ZnResponse noContent.
	response headers at: 'Date' put: ( ZnUtils httpDate: dateTime ).
	^ response
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
		assertHasTheExpectedContents: resource;
		assert: ( resource isExpiredAt: currentDateTime );
		assert: ( resource isExpiredAt: currentDateTime + 1 second );
		assert: ( resource isExpiredAt: currentDateTime - 1 second ).

	resource := self resourceOriginatedAt: currentDateTime expiresContaining: '0'.
	self
		assertHasTheExpectedContents: resource;
		assert: ( resource isExpiredAt: currentDateTime );
		assert: ( resource isExpiredAt: currentDateTime + 1 second );
		assert: ( resource isExpiredAt: currentDateTime - 1 second )
]

{ #category : #tests }
ExpiringResourceTest >> testIsExpiredAtUsingExpires [

	| resource |

	resource := self resourceOriginatedAt: currentDateTime expiringAt: currentDateTime.
	self
		assertHasTheExpectedContents: resource;
		assert: ( resource isExpiredAt: currentDateTime );
		deny: ( resource isExpiredAt: currentDateTime - 1 second );
		assert: ( resource isExpiredAt: currentDateTime + 1 second ).

	resource := self resourceOriginatedAt: currentDateTime expiringAt: currentDateTime + 55 seconds.
	self
		assertHasTheExpectedContents: resource;
		deny: ( resource isExpiredAt: currentDateTime );
		deny: ( resource isExpiredAt: currentDateTime - 1 second );
		deny: ( resource isExpiredAt: currentDateTime + 1 second );
		assert: ( resource isExpiredAt: currentDateTime + 55 seconds );
		assert: ( resource isExpiredAt: currentDateTime + 56 seconds )
]

{ #category : #tests }
ExpiringResourceTest >> testIsExpiredAtUsingMaxAge [

	| resource |

	resource := self resourceOriginatedAt: currentDateTime expiringIn: 0 seconds.
	self
		assertHasTheExpectedContents: resource;
		assert: ( resource isExpiredAt: currentDateTime );
		deny: ( resource isExpiredAt: currentDateTime - 1 second );
		assert: ( resource isExpiredAt: currentDateTime + 1 second ).

	resource := self resourceOriginatedAt: currentDateTime expiringIn: 55 seconds.
	self
		assertHasTheExpectedContents: resource;
		deny: ( resource isExpiredAt: currentDateTime );
		deny: ( resource isExpiredAt: currentDateTime - 1 second );
		deny: ( resource isExpiredAt: currentDateTime + 1 second );
		assert: ( resource isExpiredAt: currentDateTime + 55 seconds );
		assert: ( resource isExpiredAt: currentDateTime + 56 seconds )
]

{ #category : #tests }
ExpiringResourceTest >> testIsExpiredAtUsingNoCache [

	| resource |

	resource := self resourceWithNoCacheDirectiveOriginatedAt: currentDateTime.
	self
		assertHasTheExpectedContents: resource;
		assert: ( resource isExpiredAt: currentDateTime );
		deny: ( resource isExpiredAt: currentDateTime - 1 second );
		assert: ( resource isExpiredAt: currentDateTime + 1 second );
		assert: ( resource isExpiredAt: currentDateTime + 55 seconds );
		assert: ( resource isExpiredAt: currentDateTime + 56 seconds )
]

{ #category : #tests }
ExpiringResourceTest >> testIsExpiredAtUsingNoCacheAndMaxAge [

	| resource |

	resource := self resourceWithNoCacheDirectiveOriginatedAt: currentDateTime expiringIn: 55 seconds.
	self
		assertHasTheExpectedContents: resource;
		assert: ( resource isExpiredAt: currentDateTime );
		deny: ( resource isExpiredAt: currentDateTime - 1 second );
		assert: ( resource isExpiredAt: currentDateTime + 1 second );
		assert: ( resource isExpiredAt: currentDateTime + 55 seconds );
		assert: ( resource isExpiredAt: currentDateTime + 56 seconds )
]

{ #category : #tests }
ExpiringResourceTest >> testIsExpiredAtWithoutCacheDirectives [

	| resource response |

	response := self responseWithDateHeader: currentDateTime.
	resource := self expiringResourceControlledBy: response.
	self
		assertHasTheExpectedContents: resource;
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
		assertHasTheExpectedContents: resource;
		assert: resource hasExpiredAt: currentDateTime;
		assert: resource hasExpiredAt: currentDateTime + 1 second;
		assert: resource expiresIn: 1 second at: currentDateTime - 1 second.

	resource := self resourceOriginatedAt: currentDateTime expiringAt: currentDateTime + 55 seconds.

	self
		assertHasTheExpectedContents: resource;
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
		assertHasTheExpectedContents: resource;
		assert: resource hasExpiredAt: currentDateTime;
		assert: resource hasExpiredAt: currentDateTime + 1 second;
		assert: resource expiresIn: 1 second at: currentDateTime - 1 second.

	resource := self resourceOriginatedAt: currentDateTime expiringIn: 55 seconds.

	self
		assertHasTheExpectedContents: resource;
		assert: resource expiresIn: 55 seconds at: currentDateTime;
		assert: resource expiresIn: 56 seconds at: currentDateTime - 1 second;
		assert: resource expiresIn: 54 seconds at: currentDateTime + 1 second;
		assert: resource hasExpiredAt: currentDateTime + 1 minute
]
