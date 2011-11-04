#! /bin/sh

cd ../

mkdir ~/tmp/BrokerDocumentation
cp -R Documentation/com.andrewbsmith.broker.Broker.docset/Contents/Resources/Documents ~/tmp/BrokerDocumentation
git checkout gh-pages
cp -R ~/tmp/BrokerDocumentation .
git push origin gh-pages
