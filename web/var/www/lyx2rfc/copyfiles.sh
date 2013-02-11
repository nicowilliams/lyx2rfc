#!/bin/bash

basedir=/var/local/lyx2rfc/lyx2rfc-master
target=./files

mkdir -p $target

cp $basedir/test/test-i-d.lyx $target
cp $basedir/doc/lyx2rfc-user-guide.lyx $target
cp $basedir/doc/lyx2rfc-user-guide.html $target

