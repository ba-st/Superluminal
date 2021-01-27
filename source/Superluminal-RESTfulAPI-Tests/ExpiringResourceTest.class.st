"
An ExpiringResourceTest is a test class for testing the behavior of ExpiringResource
"
Class {
	#name : #ExpiringResourceTest,
	#superclass : #TestCase,
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #tests }
ExpiringResourceTest >> currentDateAndTime [

	^ DateAndTime now truncated
]

{ #category : #tests }
ExpiringResourceTest >> testExpiredWhenExpiresSetToInvalidDate [

	"A cache recipient MUST interpret invalid date formats, especially the
   value 0, as representing a time in the past (i.e., 'already
   expired').

	See: https://tools.ietf.org/html/rfc7234#section-5.3"

	| dateTime headers resource response |

	dateTime := self currentDateAndTime.
	headers := Dictionary new
		at: 'Date' put: ( ZnUtils httpDate: dateTime );
		at: 'Expires' put: 'not-a-date';
		yourself.
	response := ZnResponse noContent
		headers: headers;
		yourself.
	resource := ExpiringResource for: 'here' controlledBy: response.
	self
		assert: resource contents equals: 'here';
		assert: ( resource isExpiredAt: dateTime );
		assert: ( resource isExpiredAt: dateTime + 1 second );
		assert: ( resource isExpiredAt: dateTime - 1 second )
]

{ #category : #tests }
ExpiringResourceTest >> testExpiredWhenExpiresSetToZero [

	"A cache recipient MUST interpret invalid date formats, especially the
   value 0, as representing a time in the past (i.e., 'already
   expired').

	See: https://tools.ietf.org/html/rfc7234#section-5.3"

	| dateTime headers resource response |

	dateTime := self currentDateAndTime.
	headers := Dictionary new
		at: 'Date' put: ( ZnUtils httpDate: dateTime );
		at: 'Expires' put: '0';
		yourself.
	response := ZnResponse noContent
		headers: headers;
		yourself.
	resource := ExpiringResource for: 'here' controlledBy: response.
	self
		assert: resource contents equals: 'here';
		assert: ( resource isExpiredAt: dateTime );
		assert: ( resource isExpiredAt: dateTime + 1 second );
		assert: ( resource isExpiredAt: dateTime - 1 second )
]

{ #category : #tests }
ExpiringResourceTest >> testIsExpiredAtUsingExpires [

	| dateTime headers resource response |

	dateTime := self currentDateAndTime.
	headers := Dictionary new
		at: 'Date' put: ( ZnUtils httpDate: dateTime );
		at: 'Expires' put: ( ZnUtils httpDate: dateTime + 55 seconds );
		yourself.
	response := ZnResponse noContent
		headers: headers;
		yourself.
	resource := ExpiringResource for: 'here' controlledBy: response.
	self
		assert: resource contents equals: 'here';
		deny: ( resource isExpiredAt: dateTime );
		deny: ( resource isExpiredAt: dateTime - 1 second);
		deny: ( resource isExpiredAt: dateTime + 1 second );
		deny: ( resource isExpiredAt: dateTime + 55 seconds );		
		assert: ( resource isExpiredAt: dateTime + 1 minute )
]

{ #category : #tests }
ExpiringResourceTest >> testIsExpiredAtUsingMaxAge [

	| dateTime headers resource response |

	dateTime := self currentDateAndTime.
	headers := Dictionary new
		at: 'Date' put: ( ZnUtils httpDate: dateTime );
		at: 'Cache-Control' put: #('Max-Age=0');
		yourself.
	response := ZnResponse noContent
		headers: headers;
		yourself.
	resource := ExpiringResource for: 'here' controlledBy: response.
	self
		assert: resource contents equals: 'here';
		deny: ( resource isExpiredAt: dateTime );
		deny: ( resource isExpiredAt: dateTime - 1 second );
		assert: ( resource isExpiredAt: dateTime + 1 second ).

	headers at: 'Cache-Control' put: #('Max-Age=55').
	self
		deny: ( resource isExpiredAt: dateTime );
		deny: ( resource isExpiredAt: dateTime - 1 second );
		deny: ( resource isExpiredAt: dateTime + 1 second );
		deny: ( resource isExpiredAt: dateTime + 55 seconds );
		assert: ( resource isExpiredAt: dateTime + 1 minute )
]

{ #category : #tests }
ExpiringResourceTest >> testIsExpiredAtWithoutCacheDirectives [

	| dateTime headers resource response |

	dateTime := self currentDateAndTime.
	headers := Dictionary new
		at: 'Date' put: ( ZnUtils httpDate: dateTime );
		yourself.
	response := ZnResponse noContent
		headers: headers;
		yourself.
	resource := ExpiringResource for: 'here' controlledBy: response.
	self
		assert: resource contents equals: 'here';
		assert: ( resource isExpiredAt: dateTime );
		assert: ( resource isExpiredAt: dateTime + 1 second );
		assert: ( resource isExpiredAt: dateTime + 1 minute );
		assert: ( resource isExpiredAt: dateTime + 1 hour )
]

{ #category : #tests }
ExpiringResourceTest >> testTimeToExpireAtUsingExpires [

	| dateTime headers resource response |

	dateTime := self currentDateAndTime.
	headers := Dictionary new
		at: 'Date' put: ( ZnUtils httpDate: dateTime );
		at: 'Expires' put: ( ZnUtils httpDate: dateTime + 1 minute );
		yourself.
	response := ZnResponse noContent
		headers: headers;
		yourself.
	resource := ExpiringResource for: 'here' controlledBy: response.
	self
		assert: resource contents equals: 'here';
		assert: ( resource timeToExpireAt: dateTime ) equals: 1 minute;
		assert: ( resource timeToExpireAt: dateTime + 30 seconds ) equals: 30 seconds;
		should: [ resource timeToExpireAt: dateTime + 1 minute + 1 second  ] raise: ResourceHasExpired.
]

{ #category : #tests }
ExpiringResourceTest >> testTimeToExpireAtUsingMaxAge [

	| dateTime headers resource response |

	dateTime := self currentDateAndTime.
	headers := Dictionary new
		at: 'Date' put: ( ZnUtils httpDate: dateTime );
		at: 'Cache-Control' put: #('Max-Age=0');
		yourself.
	response := ZnResponse noContent
		headers: headers;
		yourself.
	resource := ExpiringResource for: 'here' controlledBy: response.
	self
		assert: resource contents equals: 'here';
		assert: ( resource timeToExpireAt: dateTime ) equals: 0 seconds;
		should: [ resource timeToExpireAt: dateTime + 1 second ] raise: ResourceHasExpired;
		assert: ( resource timeToExpireAt: dateTime - 1 second ) equals: 1 second.
		
	headers at: 'Cache-Control' put: #('Max-Age=55').
	self
		assert: ( resource timeToExpireAt: dateTime ) equals: 55 seconds;
		assert: ( resource timeToExpireAt: dateTime - 1 second ) equals: 56 seconds;
		assert: ( resource timeToExpireAt: dateTime + 1 second ) equals: 54 seconds;
		should: [ resource timeToExpireAt: dateTime + 1 minute ] raise: ResourceHasExpired.

]
