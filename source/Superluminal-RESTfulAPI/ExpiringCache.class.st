Class {
	#name : #ExpiringCache,
	#superclass : #Object,
	#instVars : [
		'expiringResources',
		'timeSourceProvider'
	],
	#category : #'Superluminal-RESTfulAPI-Cache'
}

{ #category : #'instance creation' }
ExpiringCache class >> accordingTo: aTimeSourceProvider [

	^self new initializeAccordingTo: aTimeSourceProvider
]

{ #category : #accessing }
ExpiringCache >> clearResourceAt: aLocation [

	| urlString resourceAndSubResources |

	urlString := aLocation asUrl asString.
	resourceAndSubResources := expiringResources keys select: [ :key | key beginsWith: urlString ].
	resourceAndSubResources do: [ :key | expiringResources removeKey: key ifAbsent: [  ] ]
]

{ #category : #initialization }
ExpiringCache >> initializeAccordingTo: aTimeSourceProvider [

	expiringResources := Dictionary new.
	timeSourceProvider := aTimeSourceProvider
]

{ #category : #private }
ExpiringCache >> store: anExpiringResource at: aBuiltKey [

	expiringResources at: aBuiltKey put: anExpiringResource
]

{ #category : #accessing }
ExpiringCache >> withResourceAt: aBuiltKey obtainedUsing: aGetBlock do: aProcessBlock [

	"expiringResources
		get: aBuiltKey
		ifPresent: [ :resource | aProcessBlock value: resource contents ]
		ifAbsentPut: aGetBlock"

	
	expiringResources
		at: aBuiltKey
		ifPresent: [ :resource | 
			( resource isExpiredAt: timeSourceProvider value )
				ifTrue: [ 
					| contents |
					contents := aGetBlock value.
					self store: contents at: aBuiltKey
					]
			]
		ifAbsent: [ 
			| contents |
			contents := aGetBlock value.
			self store: contents at: aBuiltKey
			].
	^ aProcessBlock value: ( expiringResources at: aBuiltKey ) contents
]
