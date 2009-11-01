Object extend [
    
    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb-serialization'>
	"sandstoneDeepCopy works just like deepCopy until it hits another active record
	at which point the copying stops, and the actual references is returned."
	| newObject class index value |
	visitedParts at: self ifPresent: [ :it | ^ it ].
	class := self class.
	class isVariable
	    ifTrue:
		[ index := self basicSize.
		newObject := class basicNew: index.
		[ index > 0 ] whileTrue:
		    [ newObject
			basicAt: index
			put: ((self basicAt: index) sandstoneDeepCopyVisits: visitedParts).
		    index := index - 1 ]]
		ifFalse: [ newObject := class basicNew ].
	    visitedParts 
		at: self 
		put: newObject.
	    index := class instSize.
	    [ index > 0 ] whileTrue:
		[ value := self instVarAt: index.
		newObject
		    instVarAt: index
		    put: (value isSandstoneActiveRecord
			ifTrue: [ value ]
			ifFalse: [ value sandstoneDeepCopyVisits: visitedParts ]).
		    index := index - 1].
		^newObject
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb-serialization'>
	"Make components of the introspectee which are
	Sandstone active records to become references.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	self deservesSandstoneReferenceMark ifFalse: [^self].
	visitedParts at: self ifPresent: [:it | ^ it].
	visitedParts at: self put: self.
	self class allInstVarNames do:
	    [:name |
	    | var |
	    var := self instVarNamed: name.
	    var isSandstoneActiveRecord
		ifTrue:
		    [self
			instVarNamed: name
			put: var asReferenceMarker]
		ifFalse: [var sandstoneMarkReferencesVisits: visitedParts]].
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb-serialization'>
	"Make components of the introspectee which are
	Sandstone references to active record to become active records.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	self deservesSandstoneReferenceMark ifFalse: [^self].
	visitedParts at: self ifPresent: [:it | ^ it ].
	visitedParts at: self put: self.
	self class allInstVarNames do:
	    [:name |
	    | var |
	    var := self instVarNamed: name.
	    (var isSandstoneMarker)
		ifTrue:
		    [ self
			instVarNamed: name
			put: var asOriginalObject ]
		ifFalse: [var sandstoneResolveReferencesVisits: visitedParts ]].
	^self
    ]
    
    deservesSandstoneReferenceMark [
	<category: '*sandstonedb-testing'>
	^true
    ]

    isSandstoneActiveRecord [
	<category: '*sandstonedb'>

	"Answers true if the receiver is
	a Sandstone Active Record."
	^false
    ]

    isSandstoneMarker [
	<category: '*sandstonedb'>
	^false
    ]
]

Collection extend [
    
    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>
    
	"sandstoneDeepCopy works just like deepCopy until it hits another active record
	at which point the copying stops, and the actual references is returned."
	| newObject |
	visitedParts at: self ifPresent: [:it | ^it ].
	newObject := self copy.
	newObject do:
	    [:each |
	    each isSandstoneActiveRecord ifFalse:
		[ newObject remove: each.
		newObject add: (each sandstoneDeepCopyVisits: visitedParts) ]].
	visitedParts at: self put: newObject.
	^newObject
    ]
    
    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>

	"Make components of the introspectee which are
	Sandstone active records to become references.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	self deservesSandstoneReferenceMark ifFalse: [^self].
	visitedParts at: self ifPresent: [:it | ^self ].
	visitedParts at: self put: self.
	self copy do: [:each |
	    each isSandstoneActiveRecord
		ifTrue: [ self remove: each; add: each asReferenceMarker ]
		ifFalse: [ each sandstoneMarkReferencesVisits: visitedParts ]].
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
    
	"Make components of the introspectee which are
	Sandstone references to active record to become active records.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	visitedParts at: self ifPresent: [:it | ^it].
	visitedParts at: self put: self.
	"It is crucial to modify the introspectee by iterating a copy of it"
	self copy doWithIndex:
	    [:each :index |
	    each isSandstoneMarker
		ifTrue: [self at: index put: each asOriginalObject ]
		ifFalse: [ each sandstoneResolveReferencesVisits: visitedParts ]].
	^self
    ]
]

Array extend [
    
    deservesSandstoneReferenceMark [
	<category: '*sandstonedb'>
	^ {Array. WeakArray } includes: self class
    ]
]

Boolean extend [

    sandstoneDeepCopy [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]
]

Bag extend [

    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>
	"sandstoneDeepCopy works just like deepCopy until it hits another active record
	at which point the copying stops, and the actual references is returned."
	| newObject |
	visitedParts at: self ifPresent: [:it | ^ it ].
	newObject := self deepCopy.
	newObject contents sandstoneDeepCopyVisits: visitedParts.
	visitedParts at: self put: newObject.
	^newObject
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	"Make components of the introspectee which are
	Sandstone active records to become references.
	Do this deeply (sub components)."
	<category: '*sandstonedb'>

	self class isMeta ifTrue: [^self].
	self deservesSandstoneReferenceMark ifFalse: [^self].
	visitedParts at: self ifPresent: [:it | ^self].
	visitedParts at: self put: self.
	self contents sandstoneMarkReferencesVisits: visitedParts.
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	"Make components of the introspectee which are
	Sandstone references to active record to become active records.
	Do this deeply (sub components)."
	<category:'*sandstonedb'>
	
	self class isMeta ifTrue: [^self].
	visitedParts at: self ifPresent: [:it | ^it].
	visitedParts at: self put: self.
	self valuesAndCounts sandstoneResolveReferencesVisits: visitedParts.
	^self
    ]
]


Character extend [

    sandstoneDeepCopy [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]
]

Dictionary extend [
    
    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>

	"sandstoneDeepCopy works just like deepCopy until it hits another active record
	at which point the copying stops, and the actual references is returned."
	|newObject|
	visitedParts at: self ifPresent: [ :it | ^it].
	newObject := self class new: self size.
	self keysAndValuesDo:
	    [:key :value |
	    newObject 
		    at: (key sandstoneDeepCopyVisits: visitedParts)
		    put: (value sandstoneDeepCopyVisits: visitedParts)].
	visitedParts at: self put: newObject.
	^newObject
    ]	

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	
	"Make components of the instrospectee which are
	Sandstone active records to become references.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	self deservesSandstoneReferenceMark ifFalse: [^self].
	visitedParts at: self ifPresent: [:it | ^self].
	visitedParts at: self put: self.
	"it is crucial to modify the introspectee by iterating a copy of it"
	self copy keysAndValuesDo:
	    [:key :value | | newKey newValue |
	    newKey := key.
	    newValue := value.
	    key isSandstoneActiveRecord
		ifTrue: [ newKey := key asReferenceMarker ]
		ifFalse: [ key sandstoneMarkReferencesVisits:  visitedParts ].
	    value isSandstoneActiveRecord
		ifTrue: [ newKey := key asReferenceMarker ]
		ifFalse: [ value sandstoneMarkReferencesVisits: visitedParts ].
	    key = newKey put: newValue ].
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	
	"Make components of the introspectee which are
	Sandstone references to active record to become active records.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	visitedParts at: self ifPresent: [ :it | ^ it ].
	visitedParts at: self put: self.
	"It is crucial to modify the introspectee by iterating a copy of it"
	self copy keysAndValuesDo:
	    [ :key :value | | newKey newValue |
	    newKey := key.
	    newValue := value.
	    key isSandstoneMarker
		ifTrue: [ newKey := key asOriginalObject ]
		ifFalse: [ key sandstoneResolveReferencesVisits: visitedParts ].
	key = newKey ifFalse: [ self removeKey: key ].
	self at: newKey put: newValue ].	
    ^self
    ]
]

Integer extend [
    
    asReducedSumOfDigits [
	"Answers the sum of the digits present in the
	decimal representation of the receiver
	but also repeating the procedure if the answers is greater than 9."
	
	^10 <= self
	    ifFalse: [self]
	    ifTrue:
		[self = 10
		    ifTrue: [0]
		    ifFalse:
			[(self printString
			    inject: 0
			    into: [:sum :e | sum + e digitValue ]) asReducedSumOfDigits ]]
    ]
]

LookupKey extend [

    deservesSandstoneReferenceMark [
    <category: '*sandstonedb'>
    ^true
    ]
]

Magnitude extend [
    
    deservesSandstoneReferenceMark [
	<category: '*sandstonedb'>
	^false
    ]
]

Number extend [
    
    sandstoneDeepCopy [
	<category: '*sandstonedb'>
	^self
    ]
	
    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]
    
    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]
]

SequenceableCollection extend [

    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>
	
	"sandstoneDeepCopy works just like deepCopy until it hits another active record
	at which point the copying stops, and the actual references is returned."
	| newObject |
	visitedParts 
	    at: self 
	    ifPresent: [:it | ^it ].
	newObject := self copy.
	"optimized implementation taking advantaged of ordering"
	newObject doWithIndex:
	    [:each :index |
	    each isSandstoneActiveRecord ifFalse:
		[ newObject 
		    at: index 
		    put: (each sandstoneDeepCopyVisits: visitedParts)]].
	visitedParts
	    at: self
	    put: newObject.
	^newObject
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	
	"Make components of the introspectee which are
	Sandstone active records to become references.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	self deservesSandstoneReferenceMark ifFalse: [^self].
	visitedParts at: self ifPresent: [:it | ^self].
	visitedParts at: self put: self.
	self doWithIndex:
	    [:each :index |
	    each isSandstoneActiveRecord
		ifTrue: [self at: index put: each asReferenceMarker]
		ifFalse: [each sandstoneMarkReferencesVisits: visitedParts]].
	^self
    ]	
]

Set extend [

    doWithIndex: aBlock [
	<category: 'enumerating'>
	"Support Set enumeration with a counter, even though not ordered"
	| index |
	index := 0.
	self do: [:item | aBlock value: item value: (index := index+1)]
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	
	"Make components of the introspectee which are
	Sandstone references to active record to become active records.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	visitedParts at: self ifPresent: [:it | ^it].
	visitedParts at: self put: self.
	"It is crucial to modify the introspectee by iterating a copy of it"
	self copy doWithIndex:
	    [:each :index |
	    each isSandstoneMarker
		ifTrue: [self remove: each; add: each asOriginalObject]
		ifFalse: [each sandstoneResolveReferencesVisits: visitedParts]].
	^self
    ]
]

String extend [
    
    sandstoneDeepCopy [
	<category: '*sandstonedb-serialization'>
	^self shallowCopy
    ]

    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb-serialization'>
	^self shallowCopy
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb-serialization'>
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb-serialization'>
	^self
    ]
]

UndefinedObject extend [
    
    sandstoneDeepCopy [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]
]
