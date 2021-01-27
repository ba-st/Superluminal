Class {
	#name : #APIClientTest,
	#superclass : #TestCase,
	#instVars : [
		'teachableHttpClient'
	],
	#category : #'Superluminal-SUnit-Model'
}

{ #category : #testing }
APIClientTest class >> isAbstract [

	^ self = APIClientTest
]

{ #category : #'private - utility' }
APIClientTest >> configure: httpClient toRespondWith: response [

	httpClient whenSend: #response return: response
]

{ #category : #'private - utility' }
APIClientTest >> configure: httpClient toRespondWithAll: responses [

	| responseQueue |

	responseQueue := OrderedCollection withAll: responses.
	httpClient whenSend: #response evaluate: [ responseQueue removeFirst ]
]

{ #category : #'private - utility' }
APIClientTest >> configureHttpClientToRespondWith: response [

	self configure: teachableHttpClient toRespondWith: response
]

{ #category : #'private - utility' }
APIClientTest >> configureHttpClientToRespondWithAll: responses [

	self configure: teachableHttpClient toRespondWithAll: responses
]

{ #category : #'private - utility' }
APIClientTest >> httpClient [

	^ teachableHttpClient
]

{ #category : #'private - utility' }
APIClientTest >> jsonOkResponseWith: jsonPayload [

	^ ZnResponse
		ok:
			( ZnEntity
				json:
					( jsonPayload isString
						then: [ jsonPayload ]
						otherwise: [ NeoJSONWriter toStringPretty: jsonPayload ] ) )
]

{ #category : #'private - utility' }
APIClientTest >> newTeachableHttpClient [

	^ Teachable new
		acceptSend: #url:;
		acceptSend: #contents:;
		acceptSend: #entity:;
		acceptSend: #headerAt:put:;
		acceptSend: #queryAt:put:;
		acceptSend: #accept:;
		acceptSend: #close;
		acceptSend: #method:;
		acceptSend: #timeout:;
		acceptSend: #execute;
		acceptSend: #resetRequest;
		yourself
]

{ #category : #running }
APIClientTest >> setUp [

	super setUp.
	teachableHttpClient := self newTeachableHttpClient
]
