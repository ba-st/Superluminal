"
An ExpiringCacheKeyBuilderTest is a test class for testing the behavior of ExpiringCacheKeyBuilder
"
Class {
	#name : 'ExpiringCacheKeyBuilderTest',
	#superclass : 'TestCase',
	#category : 'Superluminal-RESTfulAPI-Tests-Cache',
	#package : 'Superluminal-RESTfulAPI-Tests',
	#tag : 'Cache'
}

{ #category : 'test' }
ExpiringCacheKeyBuilderTest >> testEntity [

  | httpRequest key |
  httpRequest := HttpRequest
                   post: 'http://google.com'
                   configuredUsing: [ :request |
                     request body
                       contents: '{"name":"original"}'
                       encodedAs: ZnMimeType applicationJson ].

  key := ExpiringCacheKeyBuilder keyFor: httpRequest at: 'http://google.com'.
  self assert: key equals: 'http://google.com/|entity[{"name":"original"}]'
]

{ #category : 'test' }
ExpiringCacheKeyBuilderTest >> testFormAtAdd [

	| httpRequest key |

	httpRequest := HttpRequest
		post: 'http://google.com'
		configuredUsing: [ :request | request body formUrlEncoded: [ :form | form fieldNamed: 'query' pairedTo: 'ba-st' ] ].

	key := ExpiringCacheKeyBuilder keyFor: httpRequest at: 'http://google.com'.
	self assert: key equals: 'http://google.com/|form-query[ba-st]'
]

{ #category : 'test' }
ExpiringCacheKeyBuilderTest >> testHeaderAtPut [

  | httpRequest key |
  httpRequest := HttpRequest
                   post: 'http://google.com'
                   configuredUsing: [ :request | request headers setBearerTokenTo: '123' ].

  key := ExpiringCacheKeyBuilder keyFor: httpRequest at: 'https://google.com'.
  self
    assert: key asLowercase
    equals: 'https://google.com/|header-authorization[d8006d79bb0c03c58a17b31d3dbead8e65dcd2b00ee7f7b7447d30af255af56e]'.

  httpRequest := HttpRequest
                   post: 'http://google.com'
                   configuredUsing: [ :request |
                     request headers set: #'Another-Header' to: 'Something' ].

  key := ExpiringCacheKeyBuilder keyFor: httpRequest at: 'https://google.com'.
  self assert: key equals: 'https://google.com/'
]
