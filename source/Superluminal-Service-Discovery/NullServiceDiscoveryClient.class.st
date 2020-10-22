Class {
	#name : #NullServiceDiscoveryClient,
	#superclass : #ServiceDiscoveryClient,
	#category : #'Superluminal-Service-Discovery'
}

{ #category : #accessing }
NullServiceDiscoveryClient >> withLocationOfService: serviceName do: foundBlock ifUnable: failBlock [

	^ failBlock value
]
