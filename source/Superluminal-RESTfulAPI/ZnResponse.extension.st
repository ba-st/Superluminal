Extension { #name : #ZnResponse }

{ #category : #'*Superluminal-RESTfulAPI' }
ZnResponse >> canBeStoredInCache [

	^ self cachingDirectives noneSatisfy: [ :directive | directive asLowercase = 'no-store' ]
]
