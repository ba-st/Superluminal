"
A NullServiceDiscoveryClientTest is a test class for testing the behavior of NullServiceDiscoveryClient
"
Class {
	#name : #NullServiceDiscoveryClientTest,
	#superclass : #TestCase,
	#category : #'Superluminal-Service-Discovery-Tests'
}

{ #category : #test }
NullServiceDiscoveryClientTest >> testWithLocationOfServiceDoIfUnable [

	| serviceLookupWasUnsuccesfull |
	serviceLookupWasUnsuccesfull := false.

	NullServiceDiscoveryClient new
		withLocationOfService: #google
		do: [ :location | self fail ]
		ifUnable: [ serviceLookupWasUnsuccesfull := true ].

	self assert: serviceLookupWasUnsuccesfull
]
