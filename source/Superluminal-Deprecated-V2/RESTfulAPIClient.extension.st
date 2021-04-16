Extension { #name : #RESTfulAPIClient }

{ #category : #'*Superluminal-Deprecated-V2' }
RESTfulAPIClient class >> buildingHttpClientWith: anHttpClientProvider [

	self
		deprecated: 'Use #buildingHttpClientWith:cachingIn: '
		on: '2021-03-23'
		in: 'v2'
		transformWith:
			'`@receiver buildingHttpClientWith: `@provider'
				-> '`@receiver buildingHttpClientWith: `@provider cachingIn: ExpiringCache onLocalMemory'.

	^ self buildingHttpClientWith: anHttpClientProvider cachingIn: ExpiringCache onLocalMemory
]

{ #category : #'*Superluminal-Deprecated-V2' }
RESTfulAPIClient class >> default [

	self
		deprecated: 'Use #cachingOnLocalMemory'
		on: '2021-03-23'
		in: 'v2'
		transformWith: '`@receiver default' -> '`@receiver cachingOnLocalMemory'.

	^ self cachingOnLocalMemory
]
