Extension { #name : #ExpiringCache }

{ #category : #'*Superluminal-Deprecated-V2' }
ExpiringCache class >> accordingTo: aTimeSourceProvider [

	self
		deprecated: 'Use #persistingTo: instead or any of the convenience messages available'
		on: '2021-03-23'
		in: 'v2'
		transformWith:
			'`@receiver accordingTo: `@timeSourceProvider'
				-> '`@receiver persistingTo: ( LocalMemoryCacheRepository using: `@timeSourceProvider )'.

	^ self persistingTo: ( LocalMemoryCacheRepository using: aTimeSourceProvider )
]
