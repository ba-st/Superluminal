Extension { #name : #BlockClosure }

{ #category : #'*Superluminal-Model' }
BlockClosure >> asHttpRequestCommand [

	^ (self cull: HttpRequestConfigurator new) ifNil: [ CompositeHttpRequestCommand empty ]
]
