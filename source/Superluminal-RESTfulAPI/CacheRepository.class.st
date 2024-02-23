Class {
	#name : 'CacheRepository',
	#superclass : 'Object',
	#category : 'Superluminal-RESTfulAPI-Cache',
	#package : 'Superluminal-RESTfulAPI',
	#tag : 'Cache'
}

{ #category : 'protocol' }
CacheRepository >> get: aKey [

	^ self subclassResponsibility 
]

{ #category : 'removing' }
CacheRepository >> remove: aKey [
	
	self subclassResponsibility 
]

{ #category : 'management' }
CacheRepository >> store: anExpiringResource at: aKey [

	self subclassResponsibility 
]
