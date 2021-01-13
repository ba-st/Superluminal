"
A ConsulAgentHttpAPIBasedDiscoveryClientTest is a test class for testing the behavior of ConsulAgentHttpAPIBasedDiscoveryClient
"
Class {
	#name : #ConsulAgentHttpAPIBasedDiscoveryClientTest,
	#superclass : #TestCase,
	#instVars : [
		'consulAgent',
		'port'
	],
	#category : #'Superluminal-Service-Discovery-Tests'
}

{ #category : #accessing }
ConsulAgentHttpAPIBasedDiscoveryClientTest >> consulAgentLocation [ 

	^ 'http://localhost' asUrl port: port
]

{ #category : #running }
ConsulAgentHttpAPIBasedDiscoveryClientTest >> setUp [

	super setUp.
	port := self freeListeningTCPPort.
	consulAgent := StubbedConsulAgentHealthHttpAPI
		               configuredBy: { 
				               #port -> port.
				               #serverUrl -> self consulAgentLocation.
				               #debugMode -> true }
		               on: self.
	consulAgent start
]

{ #category : #running }
ConsulAgentHttpAPIBasedDiscoveryClientTest >> tearDown [

	consulAgent ifNotNil: #stop.
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
