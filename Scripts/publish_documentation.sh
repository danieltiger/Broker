#! /bin/sh

cd ../

mkdir ~/Documents/tmp
mkdir ~/Documentation/tmp/BrokerDocumentation
cp -R Documentation/com.andrewbsmith.broker.Broker.docset/Contents/Resources/Documents ~/Documents/tmp/BrokerDocumentation
git checkout gh-pages
cp -R ~/Documents/tmp/BrokerDocumentation .
git push origin gh-pages
