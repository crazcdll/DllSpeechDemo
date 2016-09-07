# DllSpeechDemo
利用微软提供的语音识别 SDK 实现的 Demo，可以实现基本的语音识别功能

## 工程项目需要添加如下 Framwork，以下3个 Xcode 有提供。
1. CoreAudio.framework
2. AVFoundation.framework
3. AudioToolbox.framework
还需要添加微软提供的 SpeechSDK.framework，添加后还需要在 Building Phases 中 添加一条 copy file phase，如下图
![]()

使用总结：
1. SpeechSDK.framework/Headers/SpeechRecognitionService.h 这个头文件中，能看到的只有怎么发送数据，怎么接收数据和怎么显示数据，看不到怎么处理数据。
2. SDK 中使用了很多同步和异步操作
3. 因为前两点原因，在使用的时候要注意调用的问题。比如我想把视线语音识别的功能单独写一个类，然后在主类中调用，但是我写完了发现，我发送数据过去后，马上就输出 null 结果，因为这时候后台在处理数据，我重写的方法跟接收返回结果的方法是异步的。
4. 暂时不知道怎么解决。打算尝试用 代理，子类试试。

