Class {
	#name : #ServiceDiscoveryClient,
	#superclass : #Object,
	#category : #'Superluminal-Service-Discovery'
}

{ #category : #accessing }
ServiceDiscoveryClient >> withLocationOfService: serviceName do: foundBlock ifUnable: failBlock [

	self subclassResponsibility 
]
