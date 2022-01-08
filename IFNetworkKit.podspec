#
# Be sure to run `pod lib lint IFNetworkKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IFNetworkKit'
  s.version          = '0.0.0.1'
  s.summary          = '基于AFNetworking的网络封装'

  s.description      = <<-DESC
  1. 支持GET/POST/HEAD/PUT/DELETE/PATCH请求方法、基本的网络请求
  2. 支持下载（断点续传）
  3. 支持MultiFormData格式的数据上传
  4. 支持自定义请求的回调（请求开始、请求成功、请求失败、请求进度）
  5. 支持自定义请求的拦截器，响应体校验器、签名算法、响应内容序列化规则、请求分类
  6. 支持基于分类的网络请求配置
  7. 支持响应内容的默认序列化操作IFModelRequest
                       DESC
  s.homepage         = 'https://ifgitlab.gwm.cn/iov-ios/IFNetworkKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '张高磊' => 'mrglzh@yeah.net' }
  s.source           = { :git => 'http://10.255.35.174/iov-ios/IFNetworkKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'IFNetworkKit/Classes/**/*'
  s.dependency 'AFNetworking'


    s.subspec 'IFModel' do |mSpec|
    mSpec.source_files = 'IFNetworkKit/Classes/IFModel/**/*'
    end
end
