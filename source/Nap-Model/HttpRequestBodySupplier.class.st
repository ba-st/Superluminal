Class {
	#name : #HttpRequestBodySupplier,
	#superclass : #Object,
	#instVars : [
		'commands'
	],
	#category : #'Nap-Model-Builders'
}

{ #category : #configuring }
HttpRequestBodySupplier >> contents: anEntity [

	^ SetBodyCommand to: anEntity
]

{ #category : #configuring }
HttpRequestBodySupplier >> contents: anObject encodedAs: aMediaType [

	^ self contents: (ZnEntity with: anObject type: aMediaType)
]

{ #category : #configuring }
HttpRequestBodySupplier >> formUrlEncoded: aBuildingBlock [

	| builder |

	builder := FormUrlEncodedBodyBuilder new.
	aBuildingBlock value: builder.
	^ builder build
]

{ #category : #configuring }
HttpRequestBodySupplier >> json: aDictionary [

	| json |

	json := NeoJSONWriter toString: aDictionary.
	^ SetBodyCommand to: (ZnStringEntity json: json)
]
