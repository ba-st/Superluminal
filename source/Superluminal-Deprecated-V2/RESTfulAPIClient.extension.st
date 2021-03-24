Extension { #name : #RESTfulAPIClient }

{ #category : #'*Superluminal-Deprecated-V2' }
RESTfulAPIClient class >> default [

	self
		deprecated: 'Use #cachingOnLocalMemory'
		on: '2021-03-23'
		in: 'v2'
		transformWith: '`@receiver default' -> '`@receiver cachingOnLocalMemory'.
		
	^ self cachingOnLocalMemory 
]
