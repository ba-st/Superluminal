"
A ConsulAgentHttpAPIBasedDiscoveryClientTest is a test class for testing the behavior of ConsulAgentHttpAPIBasedDiscoveryClient
"
Class {
	#name : #ConsulAgentHttpAPIBasedDiscoveryClientTest,
	#superclass : #TestCase,
	#instVars : [
		'consulAgent'
	],
	#category : #'Superluminal-Service-Discovery-Tests'
}

{ #category : #accessing }
ConsulAgentHttpAPIBasedDiscoveryClientTest >> consulAgentLocation [ 

	^ 'http://localhost' asUrl port: self port
]

{ #category : #accessing }
ConsulAgentHttpAPIBasedDiscoveryClientTest >> port [

	^ 9998
]

{ #category : #running }
ConsulAgentHttpAPIBasedDiscoveryClientTest >> setUp [

	super setUp.
	consulAgent := StubbedConsulAgentHealthHttpAPI
		               configuredBy: { 
				               #port -> self port.
				               #serverUrl -> self consulAgentLocation.
				               #debugMode -> true }
		               on: self.
	consulAgent start
]

{ #category : #running }
ConsulAgentHttpAPIBasedDiscoveryClientTest >> tearDown [

	consulAgent stop.
	super tearDown
]

{ #category : #tests }
ConsulAgentHttpAPIBasedDiscoveryClientTest >> testFoundLocation [

	| discoveryClient locationWasFound |

	discoveryClient := ConsulAgentHttpAPIBasedDiscoveryClient queryingAgentOn: self consulAgentLocation.

	locationWasFound := false.

	discoveryClient
		withLocationOfService: #mns
		do: [ :location | 
			locationWasFound := true.
			self assertUrl: location equals: ( ZnUrl new
					  host: '01649d6c4b01';
					  port: 60666 )
			]
		ifUnable: [ self fail ].

	self assert: locationWasFound
]

{ #category : #tests }
ConsulAgentHttpAPIBasedDiscoveryClientTest >> testUnableToFindLocation [

	| discoveryClient locationWasFound |

	discoveryClient := ConsulAgentHttpAPIBasedDiscoveryClient queryingAgentOn: self consulAgentLocation.

	locationWasFound := true.

	discoveryClient withLocationOfService: #'google-finance'
		do: [ :location | self fail ]
		ifUnable: [ locationWasFound := false ].

	self deny: locationWasFound
]
