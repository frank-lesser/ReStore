﻿"Filed out from Dolphin Smalltalk 7"!

SSWReStoreDefaultTest subclass: #SSWReStoreGeneralAffiliationTest
	instanceVariableNames: 'reStore3 sessionHolder'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
SSWReStoreGeneralAffiliationTest guid: (GUID fromString: '{d3ecba65-b6c0-4b22-a531-89cc25c3f19c}')!
SSWReStoreGeneralAffiliationTest comment: 'ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore'!
!SSWReStoreGeneralAffiliationTest categoriesForClass!Unclassified! !
!SSWReStoreGeneralAffiliationTest methodsFor!

session1

	sessionHolder value: #one!

session2

	sessionHolder value: #two!

session3

	sessionHolder value: #three!

setUp

	super setUp.

	reStore3 := SSWReStore new.
	self initReStore: reStore3.
	reStore3 connect.
	self addClassesTo: reStore3.

	sessionHolder := #one asValue.
	reStore2 affiliateWith: sessionHolder using: [ :sh | sh value = #two].
	reStore3 affiliateWith: sessionHolder using: [ :sh | sh value = #three]!

tearDown

	super tearDown.

	SSWReStore reset.

	reStore3 isNil ifFalse: 
		[self releaseReStore: reStore3.
		reStore3 := nil]!

testDefaultStoredInstancesWithAffiliations

	"Test use of storedInstances with the default ReStore and other affiliated instances"

	| zoe1 zoe2 zoe3 |

	self session1.
	zoe1 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].

	self session2.
	zoe2 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].
	
	self session3.
	zoe3 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].
	
	self deny: zoe1 identicalTo:  zoe2.
	self deny: zoe2 identicalTo:  zoe3.

	self assert: zoe1 _reStore identicalTo: SSWReStore globalDefault.
	self assert: zoe1 _reStore identicalTo: reStore.

	self assert: zoe2 _reStore identicalTo: reStore2.
	self assert: zoe3 _reStore identicalTo: reStore3!

testDefaultWithAffiliations

	"Test separation of the default ReStore and nother affiliated instances"

	self session1.
	self assert: SSWReStore default identicalTo:  reStore.
	self assert: ReStore identicalTo:  reStore.

	self session2.
	self assert: SSWReStore default identicalTo:  reStore2.
	self assert: ReStore identicalTo:  reStore.

	self session3.
	self assert: SSWReStore default identicalTo: reStore3.
	self assert: ReStore identicalTo: reStore.
!

testDisaffiliation

	"Test a session disaffiliated from its ReStore returns to the default global ReStore"

	| zoe1 zoe2 zoe3 |

	reStore2 disaffiliateWith: sessionHolder.
	
	self session1.
	zoe1 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].

	self session2.
	self assert: SSWReStore default == reStore.
	zoe2 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].
	
	self session3.
	zoe3 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].
	
	self assert: zoe1 identicalTo: zoe2.
	self deny: zoe2 identicalTo:  zoe3.

	self assert: zoe1 _reStore identicalTo:  reStore.
	self assert: zoe2 _reStore identicalTo:  reStore.
	self assert: zoe3 _reStore identicalTo:  reStore3!

testExistingStoreWithAffiliations

	"Test that a store of an existing object stores in the object's reStore, not the current default (affiliated or global)"

	| zoe1 john1 david1 zoe2 john2 david2 zoe3 john3 david3 |

	self session1.
	zoe1 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].
	zoe1 emailAddress: 'ztest1'.
	john1 := SimplePerson storedInstances detect: [ :each | each fullName = 'John Smith'].
	john1 emailAddress: 'jtest1'.
	david1 := SimplePerson storedInstances detect: [ :each | each fullName = 'David Smythe'].
	david1 emailAddress: 'dtest1'.
	
	self session2.
	zoe2 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].
	zoe2 emailAddress: 'ztest2'.
	john2 := SimplePerson storedInstances detect: [ :each | each fullName = 'John Smith'].
	john2 emailAddress: 'jtest2'.
	david2 := SimplePerson storedInstances detect: [ :each | each fullName = 'David Smythe'].
	david2 emailAddress: 'dtest2'.

	self session3.
	zoe3 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].
	zoe3 emailAddress: 'ztest3'.
	john3 := SimplePerson storedInstances detect: [ :each | each fullName = 'John Smith'].
	john3 emailAddress: 'jtest3'.
	david3 := SimplePerson storedInstances detect: [ :each | each fullName = 'David Smythe'].
	david3 emailAddress: 'dtest3'.

	zoe1 store.
	john2 store.
	david3 store.
	self refreshDelay.

	self session1.
	self assert: (SimplePerson storedInstances detect: [ :each | each emailAddress = 'ztest1']) identicalTo:  zoe1.
	self assert: (SimplePerson storedInstances detect: [ :each | each emailAddress = 'jtest2']) identicalTo:  john1.
	self assert: (SimplePerson storedInstances detect: [ :each | each emailAddress = 'dtest3']) identicalTo:  david1!

testMultipleAffiliationsWithSameReStore

	"Test a ReStore affiliated with two different sessions results in the same objects"

	| zoe2 zoe3 |

	"Also affiliate reStore2 with session three"
	reStore3 disaffiliateWith: sessionHolder.
	reStore2 affiliateWith: sessionHolder using: [ :sh | sh value = #two or: [sh value = #three]].

	self session2.
	zoe2 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].
	
	self session3.
	zoe3 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].
	
	self assert: zoe2 identicalTo:  zoe3.

	self assert: zoe2 _reStore identicalTo:  reStore2.
	self assert: zoe3 _reStore identicalTo:  reStore2!

testNewStoreInAffiliatedReStore

	"Test that a store under an affiliated ReStore stores in that ReStore, not the default"

	| alan |

	alan := self newAlan.

	self session2.
	alan store.

	self assert: alan _reStore identicalTo:  reStore2!

testObjectReStoreWithAffiliatedReStore

	"Test that a check for an existing object's reStore returns the object's reStore, not the current default (affilated or global)"

	| alan zoe1 zoe2 |

	self session1.
	alan := self newAlan.
	zoe1 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].

	self session2.
	zoe2 := SimplePerson storedInstances detect: [ :each | each fullName = 'Zoe Brown'].

	self assert: alan _reStore isNil.
	self assert: zoe1 _reStore identicalTo:  reStore.
	self assert: zoe1 _reStore identicalTo:  SSWReStore globalDefault.
	self assert: zoe2 _reStore identicalTo:  reStore2.

	self session1.
	self assert: alan _reStore isNil.
	self assert: zoe1 _reStore identicalTo:  reStore.
	self assert: zoe1 _reStore identicalTo:  SSWReStore globalDefault.
	self assert: zoe2 _reStore identicalTo:  reStore2! !
!SSWReStoreGeneralAffiliationTest categoriesFor: #session1!public!running! !
!SSWReStoreGeneralAffiliationTest categoriesFor: #session2!public!running! !
!SSWReStoreGeneralAffiliationTest categoriesFor: #session3!public!running! !
!SSWReStoreGeneralAffiliationTest categoriesFor: #setUp!public!running! !
!SSWReStoreGeneralAffiliationTest categoriesFor: #tearDown!public!running! !
!SSWReStoreGeneralAffiliationTest categoriesFor: #testDefaultStoredInstancesWithAffiliations!public!unit tests! !
!SSWReStoreGeneralAffiliationTest categoriesFor: #testDefaultWithAffiliations!public!unit tests! !
!SSWReStoreGeneralAffiliationTest categoriesFor: #testDisaffiliation!public!unit tests! !
!SSWReStoreGeneralAffiliationTest categoriesFor: #testExistingStoreWithAffiliations!public!unit tests! !
!SSWReStoreGeneralAffiliationTest categoriesFor: #testMultipleAffiliationsWithSameReStore!public!unit tests! !
!SSWReStoreGeneralAffiliationTest categoriesFor: #testNewStoreInAffiliatedReStore!public!unit tests! !
!SSWReStoreGeneralAffiliationTest categoriesFor: #testObjectReStoreWithAffiliatedReStore!public!unit tests! !
