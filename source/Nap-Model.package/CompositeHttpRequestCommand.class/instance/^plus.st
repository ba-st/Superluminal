composing
+ aCommand

	^ self class
		ofAll:
			(OrderedCollection new
				addAll: commands;
				add: aCommand;
				yourself)