Class {
	#name : #HttpRequestBodySupplier,
	#superclass : #Object,
	#instVars : [
		'commands'
	],
	#category : #'Nap-Model-Builders'
}

{ #category : #configuring }
HttpRequestBodySupplier >> asFormUrlEncoded: aMonadycBlock [

	| builder |

	builder := FormUrlEncodedBodyBuilder new.
	aMonadycBlock value: builder.
	^ builder build
]

{ #category : #configuring }
HttpRequestBodySupplier >> asJson: aDictionary [

	| json |

	json := NeoJSONWriter toString: aDictionary.
	^ SetBodyCommand to: (ZnStringEntity json: json)
]

{ #category : #configuring }
HttpRequestBodySupplier >> to: aString encodedAs: aMediaType [
	
	^ (SetBodyCommand to: (ZnStringEntity with: aString type: aMediaType ))
]
