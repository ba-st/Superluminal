"
An ExpiringCacheKeyBuilderTest is a test class for testing the behavior of ExpiringCacheKeyBuilder
"
Class {
	#name : #ExpiringCacheKeyBuilderTest,
	#superclass : #TestCase,
	#category : #'Superluminal-RESTfulAPI-Tests'
}

{ #category : #test }
ExpiringCacheKeyBuilderTest >> testEntity [

	| httpRequest key |

	httpRequest := HttpRequest
		post: 'http://google.com'
		configuredUsing: [ :request | request body contents: '[]' encodedAs: ZnMimeType applicationJson ].

	key := ExpiringCacheKeyBuilder keyFor: httpRequest at: 'http://google.com'.
	self assert: key equals: 'http://google.com/'
]

{ #category : #test }
ExpiringCacheKeyBuilderTest >> testFormAtAdd [

	| httpRequest key |

	httpRequest := HttpRequest
		post: 'http://google.com'
		configuredUsing: [ :request | request body formUrlEncoded: [ :form | form fieldNamed: 'query' pairedTo: 'ba-st' ] ].

	key := ExpiringCacheKeyBuilder keyFor: httpRequest at: 'http://google.com'.
	self assert: key equals: 'http://google.com/|form-query[ba-st]'
]

{ #category : #test }
ExpiringCacheKeyBuilderTest >> testHeaderAtPut [

	| httpRequest key |

	httpRequest := HttpRequest
		post: 'http://google.com'
		configuredUsing: [ :request | request headers setBearerTokenTo: '123' ].

	key := ExpiringCacheKeyBuilder keyFor: httpRequest at: 'https://google.com'.
	self assert: key equals: 'https://google.com/'
]
