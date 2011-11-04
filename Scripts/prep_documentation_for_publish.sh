#! /bin/sh

# Create tmp dir to hold docs through git branch switching
cd ../
mkdir ~/Documents/tmp
mkdir ~/Documents/tmp/BrokerDocumentation

# Copy docs to tmp location
cp -R Documentation/com.andrewbsmith.broker.Broker.docset/Contents/Resources/Documents ~/Documents/tmp/BrokerDocumentation

# Checkout Pages branch
git checkout gh-pages

# Copy files from temp locaiton into branch
for x in ~/Documents/tmp/BrokerDocumentation/* 
do 
cp -R $x .
done

# Now you can check your documentation results, and commit and push if done.
