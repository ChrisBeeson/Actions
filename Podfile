
use_frameworks!

def shared_pods
    pod 'DateTools'
    pod 'ObjectMapper', '3.3.0'
    pod 'SwiftyStoreKit','0.14.0'
    pod 'Parse'
    pod 'Fabric'
    pod 'Crashlytics'
end
    

target 'Actions-OSX-Independent' do
    platform :osx, '10.11'
    shared_pods
end

target 'Actions-OSX-AppStore'do
    platform :osx, '10.11'
    shared_pods
end

target 'ActionsKit-Shared-Tests' do
    platform :osx, '10.11'
    shared_pods
end
