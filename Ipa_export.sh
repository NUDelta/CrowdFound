xcodebuild -scheme CrowdFound -workspace Crowdfound.xcworkspace clean archive -archivePath build/CrowdFound
xcodebuild -exportArchive -exportFormat ipa -archivePath "build/CrowdFound.xcarchive" -exportPath "build/CrowdFoundv2.ipa" -exportProvisioningProfile "Delta"
