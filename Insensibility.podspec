Pod::Spec.new do |s|
    s.name             = 'Insensibility'
    s.version          = '1.0.0'
    s.summary          = 'This pod have some insensibility views.'
    s.description      = <<-DESC
    I am lazy, so create this pod.
    views in this pod all use base class, just add some extention actions. others are the some as normal one.
    DESC
    
    s.homepage         = 'https://github.com/andrew020/Insensibility'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'andrew020' => 'andrew2007@foxmail.com' }
    s.source           = { :git => 'https://github.com/andrew020/Insensibility.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.ios.deployment_target = '10.0'
    s.framework = 'UIKit'
    s.swift_version = '5.0'
    
    # Reactive
    s.subspec 'Reactive' do |reactive|
        reactive.dependency 'ReactiveSwift'
        reactive.dependency 'ReactiveCocoa'
    end
    
    # ActivityButton
    s.subspec 'ActivityButton' do |activitybutton|
        activitybutton.source_files = 'Insensibility/ActivityButton/ActivityButton.swift'
    end
    s.subspec 'ActivityButtonReactive' do |activitybutton_reactive|
        activitybutton_reactive.source_files = 'Insensibility/ActivityButton/ActivityButton_Reactive.swift'
        activitybutton_reactive.dependency 'Insensibility/ActivityButton'
        activitybutton_reactive.dependency 'Insensibility/Reactive'
    end
    
    # InAppWebview
    s.subspec 'InAppWebview' do |inapp_webview|
        inapp_webview.source_files = 'Insensibility/InAppWebview/*.*'
        inapp_webview.dependency 'SnapKit'
    end
    
    # PagingTableView
    s.subspec 'PagingFetchTableView' do |pagingfetch_tableview|
        pagingfetch_tableview.source_files = 'Insensibility/PagingFetchTableView/UITableView+PagingFetch.swift'
    end
    
    # FadePresentationViewController
    s.subspec 'FadePresentationViewController' do |fadepresentationviewcontroller|
        fadepresentationviewcontroller.source_files = 'Insensibility/FadePresentationViewController/*.*'
    end
    
    # ChainCaller
    s.subspec 'ChainCaller' do |chaincaller|
        chaincaller.source_files = 'Insensibility/ChainCaller/*.*'
    end
    
end
