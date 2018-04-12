initialization
+ aComponentCommand

	^ self class
		ofAll:
			(OrderedCollection new
				addAll: commands;
				add: aComponentCommand;
				yourself)