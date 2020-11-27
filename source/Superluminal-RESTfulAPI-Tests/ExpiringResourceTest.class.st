"
An ExpiringResourceTest is a test class for testing the behavior of ExpiringResource
"
Class {
	#name : #ExpiringResourceTest,
	#superclass : #TestCase,
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #tests }
ExpiringResourceTest >> testExpirationUsingMaxAge [

	| dateTime headers resource response |

	dateTime := DateAndTime now.
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
		assert: ( resource isExpiredAt: dateTime + 1 minute )
]
