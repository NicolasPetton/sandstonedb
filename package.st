Eval [
  PackageBuilder new
    name: 'Sandstone';
    namespace: 'Sandstone';
    prereq: 'SUnit';
    testsBelow: 'Tests' matching: '*.st';
    filein: 'Core/Extensions.st';
    filein: 'Core/SDRecordMarker.st';
    filein: 'Core/SDAbstractStore.st';
    filein: 'Core/SDCachedStore.st';
    filein: 'Store/SDFileStore.st';
    filein: 'Store/SDMemoryStore.st';
    filein: 'Core/SDConcurrentDictionary.st';
    filein: 'Core/UUID.st';
    filein: 'Core/SDCheckPointer.st';
    filein: 'Core/SDActiveRecord.st';
    filein: 'Core/SDError.st';
    filein: 'Core/SDLoadError.st';
    filein: 'Core/SDCommitError.st';


    filein: 'Tests/Extensions.st';
    filein: 'Tests/SDPersonMock.st';
    filein: 'Tests/SDManMock.st';
    filein: 'Tests/SDWomanMock.st';
    filein: 'Tests/SDChildMock.st';
    filein: 'Tests/SDGrandChildMock.st';
    filein: 'Tests/FooObject.st';
    filein: 'Tests/SDActiveRecordTest.st';
    filein: 'Tests/SDMemoryStoreTest.st';
    filein: 'Tests/SDFileStoreTest.st';

    buildXml
]

