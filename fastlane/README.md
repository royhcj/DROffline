fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios test
```
fastlane ios test
```
Runs all the tests
### ios beta_fabric
```
fastlane ios beta_fabric
```
Submit a new Beta Build to Fabric

This will also make sure the profile is up to date
### ios beta_firim
```
fastlane ios beta_firim
```
Submit a new Beta Build to fir.im

This will also make sure the profile is up to date
### ios beta_pgyer
```
fastlane ios beta_pgyer
```
Submit a new Beta Build to Pgyer

This will also make sure the profile is up to date
### ios beta_testflight
```
fastlane ios beta_testflight
```
Submit a new Beta Build to Apple TestFlight

This will also make sure the profile is up to date
### ios release
```
fastlane ios release
```
Deploy a new version to the App Store
### ios add_device
```
fastlane ios add_device
```
Generate devices.txt
### ios register_a_device
```
fastlane ios register_a_device
```

### ios refresh_profiles
```
fastlane ios refresh_profiles
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
