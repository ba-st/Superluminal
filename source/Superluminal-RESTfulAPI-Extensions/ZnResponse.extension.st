Extension { #name : 'ZnResponse' }

{ #category : '*Superluminal-RESTfulAPI-Extensions' }
ZnResponse >> canBeStoredInCache [

	^ self cachingDirectives noneSatisfy: [ :directive | directive asLowercase = 'no-store' ]
]
