#!/bin/bash

echo "building sandstone package..."
gst-package -t ~/.st ./package.xml


echo "Creating image..."
{
echo "PackageLoader fileInPackage: 'Sandstone'."
echo "Sandstone.SDActiveRecord subclass: MYAC []."
echo "ObjectMemory snapshot: 'sd.im'."
} | gst

echo "Done!"
