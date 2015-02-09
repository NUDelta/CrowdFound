#!/bin/bash
# original source from http://www.thecave.com/2014/09/16/using-xcodebuild-to-export-a-ipa-from-an-archive/
xcodebuild -scheme CrowdFound -workspace Crowdfound.xcworkspace clean archive -archivePath build/CrowdFound
xcodebuild -exportArchive -exportFormat ipa -archivePath "build/CrowdFound.xcarchive" -exportPath "build/CrowdFoundv2.ipa" -exportProvisioningProfile "Delta"

