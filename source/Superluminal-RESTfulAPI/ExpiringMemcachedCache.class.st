Class {
	#name : #ExpiringMemcachedCache,
	#superclass : #Object,
	#instVars : [
		'timeSourceProvider',
		'expiringResources'
	],
	#category : #'Superluminal-RESTfulAPI-Cache'
}

{ #category : #'instance creation' }
ExpiringMemcachedCache class >> accordingTo: aTimeSourceProvider storingOn: aCache [ 

	^ self new initializeAccordingTo: aTimeSourceProvider storingOn: aCache
]

{ #category : #'instance creation' }
ExpiringMemcachedCache class >> using: aServer [
	
	^ self new initializeUsing: aServer
	
]

{ #category : #'as yet unclassified' }
ExpiringMemcachedCache >> clearResourceAt: aLocation [

	| urlString resourceAndSubResources |

	urlString := aLocation asUrl asString.
	expiringResources remove: urlString
	
]

{ #category : #initialization }
ExpiringMemcachedCache >> initializeAccordingTo: aTimeSourceProvider storingOn: aCache [
	
	expiringResources := aCache.
	timeSourceProvider := aTimeSourceProvider 
]

{ #category : #'as yet unclassified' }
ExpiringMemcachedCache >> withResourceAt: aBuiltKey obtainedUsing: aGetBlock do: aProcessBlock [

	^ expiringResources
		get: aBuiltKey
		ifPresent: [ :resource | aProcessBlock value: resource contents ]
		ifAbsentPut: aGetBlock
		expires: ( aGetBlock value expiresIn: timeSourceProvider value )
]
