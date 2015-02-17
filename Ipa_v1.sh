xcodebuild -scheme CrowdFound -workspace Crowdfound.xcworkspace clean archive -archivePath build/CrowdFound
xcodebuild -exportArchive -exportFormat ipa -archivePath "build/CrowdFound.xcarchive" -exportPath "build/CrowdFound.ipa" -exportProvisioningProfile "Delta"
