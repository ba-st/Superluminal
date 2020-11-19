Extension { #name : #MDCacheClient }

{ #category : #'*Superluminal-RESTfulAPI' }
MDCacheClient >> get: aKey ifPresent: aPresentBlock ifAbsentPut: anAbsentBlock expires: aDuration [ 
	self halt. 
	^ aPresentBlock value: (self get: aKey ifAbsentPut: anAbsentBlock expires: aDuration)
]
