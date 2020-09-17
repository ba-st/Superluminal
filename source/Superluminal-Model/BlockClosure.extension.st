Extension { #name : #BlockClosure }

{ #category : #'*Superluminal-Model' }
BlockClosure >> asHttpRequestCommand [

	^ (self cull: HttpRequestBuilder new) ifNil: [ CompositeHttpRequestCommand empty ]
]
