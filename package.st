Eval [
  PackageBuilder new
    name: 'Sandstone';
    namespace: 'Sandtone';
    testsBelow: 'Tests' matching: '*.st';
    filein: 'Core/SDAbstractStore.st';
    filein: 'Core/SDCachedStore.st';
    filein: 'Store/SDFileStore.st';
    filein: 'Store/SDMemoryStore.st';
    filein: 'Core/SDConcurrentDictionary.st';
    filein: 'Core/Extensions.st';
    filein: 'Core/UUID.st';
    filein: 'Core/SDCheckPointer.st';
    filein: 'Core/SDActiveRecord.st';
    filein: 'Core/SDError.st';
    filein: 'Core/SDLoadError.st';
    filein: 'Core/SDCommitError.st';

"
    filein: 'Tests/SDMemoryStoreTests.st';
    filein: 'Tests/SDGrandChildMock.st';
    filein: 'Tests/SDActiveRecordTests.st';
    filein: 'Tests/SDWomanMock.st';
    filein: 'Tests/SDPersonMock.st';
    filein: 'Tests/SDFileStoreTests.st';
    filein: 'Tests/FooObject.st';
    filein: 'Tests/SDChildMock.st';
    filein: 'Tests/SDManMock.st';
"
    buildXml
]

