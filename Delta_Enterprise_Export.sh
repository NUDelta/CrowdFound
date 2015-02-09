#!/bin/bash
# original source from http://www.thecave.com/2014/09/16/using-xcodebuild-to-export-a-ipa-from-an-archive/
xcodebuild clean -project CrowdFound -configuration Release -alltargets
xcodebuild archive -project CrowdFound.xcodeproj -scheme CrowdFound -archivePath CrowdFound.xcarchive
xcodebuild -exportArchive -archivePath CrowdFound.xcarchive -exportPath CrowdFound -exportFormat ipa -exportProvisioningProfile "Delta"
