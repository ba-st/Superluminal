Extension { #name : #BlockClosure }

{ #category : #'*Superluminal-Model' }
BlockClosure >> asHttpRequestCommand [

	^ (self value: HttpRequestBuilder new) ifNil: [ CompositeHttpRequestCommand empty ]
]
