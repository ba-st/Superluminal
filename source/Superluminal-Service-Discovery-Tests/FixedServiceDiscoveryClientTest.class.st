"
A FixedServiceDiscoveryClientTest is a test class for testing the behavior of FixedServiceDiscoveryClient
"
Class {
	#name : #FixedServiceDiscoveryClientTest,
	#superclass : #TestCase,
	#category : #'Superluminal-Service-Discovery-Tests'
}

{ #category : #tests }
FixedServiceDiscoveryClientTest >> testClientChaining [

	| discoveryClient fallbackClient |

	fallbackClient := FixedServiceDiscoveryClient basedOn:
		                  { #'google-finance' -> 'https://api.finance.google.com/' asUrl }
			                  asDictionary.

	discoveryClient := FixedServiceDiscoveryClient basedOn:
		                   { #reuters -> 'api.reuters.com' asUrl } asDictionary
		                   chainedWith: fallbackClient.

	discoveryClient withLocationOfService: #'google-finance'
		do: [ :location | self assertUrl: location equals: 'https://api.finance.google.com' ]
		ifUnable: [ self fail ].

	discoveryClient withLocationOfService: #reuters
		do: [ :location | self assertUrl: location equals: 'api.reuters.com' ]
		ifUnable: [ self fail ]
]

{ #category : #tests }
FixedServiceDiscoveryClientTest >> testUnableToFindLocation [

	| discoveryClient locationWasFound |

	discoveryClient := FixedServiceDiscoveryClient basedOn: Dictionary new.

	locationWasFound := true.

	discoveryClient withLocationOfService: #'google-finance'
		do: [ :location | self fail ]
		ifUnable: [ locationWasFound := false ].

	self deny: locationWasFound
]

{ #category : #tests }
FixedServiceDiscoveryClientTest >> testWithLocationOfDoIfUnable [

	| discoveryClient |

	discoveryClient := FixedServiceDiscoveryClient basedOn: { 
			                   #'google-finance' -> 'https://api.finance.google.com/' asUrl.
			                   #reuters -> 'api.reuters.com' asUrl } asDictionary.

	discoveryClient withLocationOfService: #'google-finance'
		do: [ :location | self assertUrl: location equals: 'https://api.finance.google.com' ]
		ifUnable: [ self fail ].

	discoveryClient withLocationOfService: #reuters
		do: [ :location | self assertUrl: location equals: 'api.reuters.com' ]
		ifUnable: [ self fail ]
]
