Extension { #name : 'BlockClosure' }

{ #category : '*Superluminal-Model-Extensions' }
BlockClosure >> asHttpRequestCommand [

	^ (self cull: HttpRequestBuilder new) ifNil: [ CompositeHttpRequestCommand empty ]
]
