
use_frameworks!

def shared_pods
    pod 'DateTools', '~> 1.7'
    pod 'ObjectMapper', '~> 1.2'
    pod 'SwiftyStoreKit'
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