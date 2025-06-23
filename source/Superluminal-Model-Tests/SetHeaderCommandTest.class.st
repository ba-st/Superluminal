Class {
	#name : 'SetHeaderCommandTest',
	#superclass : 'TestCase',
	#category : 'Superluminal-Model-Tests-Commands',
	#package : 'Superluminal-Model-Tests',
	#tag : 'Commands'
}

{ #category : 'tests' }
SetHeaderCommandTest >> testApplyOnWhenSettingBasicAuth [

  | httpClient command |
  httpClient := ZnClient new.
  command := SetHeaderCommand settingAuthorizationToBasicWith: 'username' and: 'secret'.
  command applyOn: httpClient.

  self
    assert: ( httpClient request headers at: #Authorization )
    equals: 'Basic dXNlcm5hbWU6c2VjcmV0'
]

{ #category : 'tests' }
SetHeaderCommandTest >> testApplyOnWhenSettingBearerTokenAuth [

  | httpClient command |
  httpClient := ZnClient new.
  command := SetHeaderCommand settingAuthorizationToBearerToken: 'token'.
  command applyOn: httpClient.

  self assert: ( httpClient request headers at: #Authorization ) equals: 'Bearer token'
]

{ #category : 'tests' }
SetHeaderCommandTest >> testCannotUseAnEmptyValue [

	self
		should: [ SetHeaderCommand settingAuthorizationTo: '' ]
		raise: InstanceCreationFailed
		withMessageText: 'An Authorization header cannot include empty directives.'
]
