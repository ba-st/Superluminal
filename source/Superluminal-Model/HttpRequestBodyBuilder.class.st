Class {
	#name : #HttpRequestBodyBuilder,
	#superclass : #Object,
	#instVars : [
		'commands'
	],
	#category : #'Superluminal-Model-Builders'
}

{ #category : #configuring }
HttpRequestBodyBuilder >> contents: anEntity [

	^ SetBodyCommand to: anEntity
]

{ #category : #configuring }
HttpRequestBodyBuilder >> contents: anObject encodedAs: aMediaType [

	^ self contents: (ZnEntity with: anObject type: aMediaType)
]

{ #category : #configuring }
HttpRequestBodyBuilder >> formUrlEncoded: aBuildingBlock [

	| builder |

	builder := FormUrlEncodedBodyBuilder new.
	aBuildingBlock value: builder.
	^ builder build
]

{ #category : #configuring }
HttpRequestBodyBuilder >> json: aDictionary [

	| json |

	json := NeoJSONWriter toString: aDictionary.
	^ SetBodyCommand to: (ZnStringEntity json: json)
]
