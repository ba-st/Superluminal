Class {
	#name : #ExpiringCacheKeyBuilder,
	#superclass : #Object,
	#instVars : [
		'location',
		'parameters'
	],
	#category : #'Superluminal-RESTfulAPI'
}

{ #category : #accessing }
ExpiringCacheKeyBuilder class >> keyFor: aRequest at: aLocation [

	| builder |

	builder := self new.
	aRequest applyOn: builder.
	builder location: aLocation.
	^ builder build
]

{ #category : #configuring }
ExpiringCacheKeyBuilder >> accept: anAcceptDirective [

	parameters at: #accept put: anAcceptDirective asString
]

{ #category : #building }
ExpiringCacheKeyBuilder >> build [

	^ String
		streamContents: [ :stream | 
			stream nextPutAll: location.
			parameters keys sorted
				do: [ :key | 
					stream
						nextPut: $|;
						nextPutAll: key asString;
						nextPut: $[;
						nextPutAll: ( parameters at: key ) asString;
						nextPut: $]
					]
			]
]

{ #category : #configuring }
ExpiringCacheKeyBuilder >> entity: entity [

	
]

{ #category : #configuring }
ExpiringCacheKeyBuilder >> execute [
]

{ #category : #configuring }
ExpiringCacheKeyBuilder >> formAt: key add: value [

	parameters at: ( 'form-<1s>' expandMacrosWith: key asString ) asSymbol put: value asString
]

{ #category : #configuring }
ExpiringCacheKeyBuilder >> headerAt: aSymbol put: aString [

]

{ #category : #initialization }
ExpiringCacheKeyBuilder >> initialize [

	super initialize.
	location := ''.
	parameters := Dictionary new
]

{ #category : #configuring }
ExpiringCacheKeyBuilder >> location: aLocation [

	location := aLocation asUrl asString
]

{ #category : #configuring }
ExpiringCacheKeyBuilder >> method: aString [

	
]

{ #category : #configuring }
ExpiringCacheKeyBuilder >> queryAt: aKey put: aString [

	parameters at: ( 'query-<1s>' expandMacrosWith: aKey asString ) asSymbol put: aString
]

{ #category : #configuring }
ExpiringCacheKeyBuilder >> resetRequest [

	
]

{ #category : #configuring }
ExpiringCacheKeyBuilder >> response [
]

{ #category : #configuring }
ExpiringCacheKeyBuilder >> setIfNoneMatchTo: anETag [

	
]

{ #category : #configuring }
ExpiringCacheKeyBuilder >> url: aUrl [

	self location: aUrl
]
