Extension { #name : #MDCacheClient }

{ #category : #'*Superluminal-RESTfulAPI' }
MDCacheClient >> get: aKey ifPresent: aPresentBlock ifAbsentPut: anAbsentBlock expires: aDuration [ 
	 
	^ aPresentBlock value: (self get: aKey ifAbsentPut: anAbsentBlock expires: aDuration)
]
