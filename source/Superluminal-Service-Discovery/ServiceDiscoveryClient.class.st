"
I'm the abstract class for service discovery clients. 

A service discovery client is responsible for providing the known location of a service given its name.
"
Class {
	#name : #ServiceDiscoveryClient,
	#superclass : #Object,
	#category : #'Superluminal-Service-Discovery'
}

{ #category : #accessing }
ServiceDiscoveryClient >> withLocationOfService: serviceName do: foundBlock ifUnable: failBlock [

	self subclassResponsibility 
]
