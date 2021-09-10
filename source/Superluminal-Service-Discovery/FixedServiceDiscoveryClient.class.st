"
I'm a service discovery client using a fixed list of service locations.

I'm useful for testing purposes or when transitioning clients not using the service discovery mechanics. I can be chained with another service discovery client as a fallback when a service is not found in my list.
"
Class {
	#name : #FixedServiceDiscoveryClient,
	#superclass : #ServiceDiscoveryClient,
	#instVars : [
		'mappings',
		'fallbackClient'
	],
	#category : #'Superluminal-Service-Discovery'
}

{ #category : #'instance creation' }
FixedServiceDiscoveryClient class >> basedOn: aDictionary [

	^ self basedOn: aDictionary chainedWith: NullServiceDiscoveryClient new
]

{ #category : #'instance creation' }
FixedServiceDiscoveryClient class >> basedOn: aDictionary chainedWith: aServiceDiscoveryClient [

	^ self new initializeOn: aDictionary chainedWith: aServiceDiscoveryClient
]

{ #category : #initialization }
FixedServiceDiscoveryClient >> initializeOn: aDictionary chainedWith: aServiceDiscoveryClient [

	mappings := aDictionary.
	fallbackClient := aServiceDiscoveryClient
]

{ #category : #accessing }
FixedServiceDiscoveryClient >> withLocationOfService: aServiceName do: foundBlock ifUnable: failBlock [

	^ mappings at: aServiceName asSymbol
		  ifPresent: foundBlock
		  ifAbsent: [ 
		  	fallbackClient withLocationOfService: aServiceName do: foundBlock ifUnable: failBlock ]
]
