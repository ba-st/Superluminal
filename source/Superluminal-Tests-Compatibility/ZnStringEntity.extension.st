Extension { #name : #ZnStringEntity }

{ #category : #'*Superluminal-Tests-Compatibility' }
ZnStringEntity class >> json: string [
	^ (self type: ZnMimeType applicationJson)
		string: string;
		yourself
]
