Class {
	#name : #HttpRequestBodyBuilder,
	#superclass : #Object,
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
	^ self contents: ( ZnStringEntity json: json )
]

{ #category : #configuring }
HttpRequestBodyBuilder >> multiPart: aBuildingBlock [

	| builder |

	builder := MultiPartBodyBuilder new.
	aBuildingBlock value: builder.
	^ builder build
]
