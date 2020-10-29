"
I'm a service discovery client that will always fail when looking up a service by its name.
"
Class {
	#name : #NullServiceDiscoveryClient,
	#superclass : #ServiceDiscoveryClient,
	#category : #'Superluminal-Service-Discovery'
}

{ #category : #accessing }
NullServiceDiscoveryClient >> withLocationOfService: serviceName do: foundBlock ifUnable: failBlock [

	^ failBlock value
]
