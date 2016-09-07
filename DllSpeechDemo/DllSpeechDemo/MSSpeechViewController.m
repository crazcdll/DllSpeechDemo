//
//  MSSpeechViewController.m
//  DllSpeechDemo
//
//  Created by zcdll on 16/9/5.
//  Copyright © 2016年 ZC. All rights reserved.
//

#import "MSSpeechViewController.h"
#include "TargetConditionals.h"
#import <UIKit/UIKit.h>

@interface MSSpeechViewController ()

@property (nonatomic, readonly) NSString *subscriptionKey;
@property (nonatomic, readonly) NSString *luisAppId;
@property (nonatomic, readonly) NSString *luisSubscriptionID;
@property (nonatomic, readonly) BOOL useMicrophone;
@property (nonatomic, readonly) bool wantIntent;
@property (nonatomic, readonly) SpeechRecognitionMode mode;
@property (nonatomic, readonly) NSString *defaultLocale;
@property (nonatomic, readonly) NSDictionary *settings;
@property (nonatomic, readonly) NSUInteger *modeIndex;
@property (nonatomic, copy) NSString *speechResult;

@end

NSString *ConvertSpeechRecoConfidenceEnumToString(Confidence confidence);
NSString *ConvertSpeechErrorToString(int errorCode);

@implementation MSSpeechViewController

- (IBAction)tempRec:(id)sender {
    
    [self audioRecognitionWithMicCient];
    
}

- (NSString *)audioRecognitionWithMicCient{
    
    [textOnScreen setString:(@"")];
    [self setText: textOnScreen];
    [[self startButton] setEnabled:NO];
    
    [self logRecognitionStart];
    
    if (self.useMicrophone) {
        if (_micClient == nil) {
            
            if (!self.wantIntent) {
                [self WriteLine:(@"--- 开始 用 Intent 麦克风 识别 ---")];
                
                _micClient = [SpeechRecognitionServiceFactory createMicrophoneClient:(self.mode) withLanguage:(self.defaultLocale) withPrimaryKey:(self.subscriptionKey) withSecondaryKey:(self.subscriptionKey) withProtocol:(self)];
            }else {
                
                _micClient = [SpeechRecognitionServiceFactory createMicrophoneClientWithIntent:(self.defaultLocale) withPrimaryKey:(self.subscriptionKey) withSecondaryKey:(self.subscriptionKey) withLUISAppID:(self.luisAppId) withLUISSecret:(self.luisSubscriptionID) withProtocol:(self)];
            }
            
        }
        
        OSStatus status = [_micClient startMicAndRecognition];
        
        if (status) {
            [self WriteLine:[[NSString alloc] initWithFormat:(@" 启动音频识别失败：%@"), ConvertSpeechErrorToString(status)]];
        }
    }
    
    return _finalResult;
    
}

//@synthesize 

// 重写 getter 方法
#pragma mark - 设置 subscription key
- (NSString *)subscriptionKey {
    
    return [self.settings objectForKey:(@"primaryKey")];
}

#pragma mark - 设置 luis

- (NSString *)luisAppId {
    
    return [self.settings objectForKey:(@"luisAppID")];
}

- (NSString *)luisSubscriptionID {
    
    return [self.settings objectForKey:(@"luisSubscriptionID")];
}

#pragma mark - 获得 microphone 权限
- (BOOL)useMicrophone{
    
    return 1;
}

#pragma mark - 是否使用 Intent
- (BOOL)wantIntent{
    
    return 0;
}

#pragma mark - 获得当前 speech recognition mode
- (SpeechRecognitionMode)mode{
    
    return SpeechRecognitionMode_ShortPhrase;
}

- (NSString *)defaultLocale{
    
    return @"zh-cn";
}

#pragma mark - settings 信息 文件转字典
- (NSDictionary *)settings{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    NSDictionary *setting = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    return setting;
}

#pragma mark - 获取识别模式
- (NSUInteger *)modeIndex{
    
    return 0;
}

#pragma mark - 初始化
- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    textOnScreen = [NSMutableString stringWithCapacity:1000];

}

#pragma mark - 添加文本
// 添加文本
- (void)setText:(NSString *)text{
    
    self.logText.text = text;
}

#pragma mark - 输出一行
// 合成一行的输出内容
- (void)WriteLine:(NSString *)text{
    
    [textOnScreen appendString:(text)];
    [textOnScreen appendString:(@"\n")];
    [self setText:textOnScreen];
    
    NSLog(@"WriteLine = %@", text);
    
}

#pragma mark - 显示log
// 在 logText 区域显示 log
-(void)logRecognitionStart {
    
    NSString *recoSource;
    
    if (self.useMicrophone) {
        recoSource = @"microphone";
    }
    
    [self WriteLine:[[NSString alloc] initWithFormat:(@"\n--- 开始 %@ %@ 语音识别 ----\n"), @"Short", self.defaultLocale]];
}

#pragma mark - 开始识别
- (IBAction)StartButton:(id)sender {
    
    [textOnScreen setString:(@"")];
    [self setText: textOnScreen];
    [[self startButton] setEnabled:NO];
    
    [self logRecognitionStart];
    
    if (self.useMicrophone) {
        if (_micClient == nil) {
            
            if (!self.wantIntent) {
                [self WriteLine:(@"--- 开始 用 Intent 麦克风 识别 ---")];
                
                _micClient = [SpeechRecognitionServiceFactory createMicrophoneClient:(self.mode) withLanguage:(self.defaultLocale) withPrimaryKey:(self.subscriptionKey) withSecondaryKey:(self.subscriptionKey) withProtocol:(self)];
            }else {
                
                _micClient = [SpeechRecognitionServiceFactory createMicrophoneClientWithIntent:(self.defaultLocale) withPrimaryKey:(self.subscriptionKey) withSecondaryKey:(self.subscriptionKey) withLUISAppID:(self.luisAppId) withLUISSecret:(self.luisSubscriptionID) withProtocol:(self)];
            }
        }
        
        OSStatus status = [_micClient startMicAndRecognition];
        
        if (status) {
            [self WriteLine:[[NSString alloc] initWithFormat:(@" 启动音频识别失败：%@"), ConvertSpeechErrorToString(status)]];
        }
    }
}

#pragma mark - 识别最佳
// 接收返回结果
- (void)onFinalResponseReceived:(RecognitionResult *)result{
    
//    _resultText.text = @"123";
    
    BOOL isFinalDicationMessage = NO;
    
    // 判断是否需要关闭 microphone
    if (nil != _micClient && self.useMicrophone && ((self.mode == SpeechRecognitionMode_ShortPhrase) || isFinalDicationMessage)) {
        
        [_micClient endMicAndRecognition];
    }
    
    // 判断是否需要启用 识别 按钮
    if (self.mode == SpeechRecognitionMode_ShortPhrase || isFinalDicationMessage) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[self startButton] setEnabled:YES];
            
        });
    }
    
    if (!isFinalDicationMessage) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self WriteLine:(@"****** 识别最佳结果 ******")];
            for (int i = 0; i < [result.RecognizedPhrase count]; i++) {
                
                RecognizedPhrase *phrase = result.RecognizedPhrase[i];
                [self WriteLine:[[NSString alloc] initWithFormat:(@"[%d] Confidence = %@ Text = \"%@\""), i, ConvertSpeechRecoConfidenceEnumToString(phrase.Confidence), phrase.DisplayText]];
                
                self.resultText.text = phrase.LexicalForm;
                
                _speechResult = phrase.LexicalForm;
                
                _finalResult = phrase.LexicalForm;
                
            }
            [self WriteLine:@""];
        });
    }
}

#pragma mark - Intent 接收结果
- (void)onIntentReceived:(IntentResult *) result{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self WriteLine:(@"--- Intent 接收结果 ---")];
        [self WriteLine:(result.Body)];
        [self WriteLine:(@"")];
    });
}

#pragma mark - Partial 接收结果，一句
- (void)onPartialResponseReceived:(NSString *)partialResult{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self WriteLine:(@"--- Partial 接收结果 ---")];
        [self WriteLine:partialResult];
        
    });
}

#pragma mark - 显示错误信息
- (void)onError:(NSString *)errorMessage withErrorCode:(int)errorCode{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[self startButton] setEnabled:YES];
        [self WriteLine:(@"--- 发生错误 ---")];
        [self WriteLine:[[NSString alloc] initWithFormat:(@"%@ %@"), errorMessage, ConvertSpeechRecoConfidenceEnumToString(errorCode)]];
        [self WriteLine:(@"")];
        
    });
}

#pragma mark - 显示麦克风状态
- (void)onMicrophoneStatus:(Boolean)recording{
    
    if (!recording) {
        
        [_micClient endMicAndRecognition];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!recording) {
            
            [[self startButton] setEnabled:YES];
        }
        [self WriteLine:[[NSString alloc] initWithFormat:(@"****** 麦克风状态： %d ******"), recording]];
    });
}

#pragma mark - 转换错误信息
NSString *ConvertSpeechErrorToString(int errorCode){
    
    switch ((SpeechClientStatus)errorCode) {
        case SpeechClientStatus_SecurityFailed:         return @"SpeechClientStatus_SecurityFailed";
        case SpeechClientStatus_LoginFailed:            return @"SpeechClientStatus_LoginFailed";
        case SpeechClientStatus_Timeout:                return @"SpeechClientStatus_Timeout";
        case SpeechClientStatus_ConnectionFailed:       return @"SpeechClientStatus_ConnectionFailed";
        case SpeechClientStatus_NameNotFound:           return @"SpeechClientStatus_NameNotFound";
        case SpeechClientStatus_InvalidService:         return @"SpeechClientStatus_InvalidService";
        case SpeechClientStatus_InvalidProxy:           return @"SpeechClientStatus_InvalidProxy";
        case SpeechClientStatus_BadResponse:            return @"SpeechClientStatus_BadResponse";
        case SpeechClientStatus_InternalError:          return @"SpeechClientStatus_InternalError";
        case SpeechClientStatus_AuthenticationError:    return @"SpeechClientStatus_AuthenticationError";
        case SpeechClientStatus_AuthenticationExpired:  return @"SpeechClientStatus_AuthenticationExpired";
        case SpeechClientStatus_LimitsExceeded:         return @"SpeechClientStatus_LimitsExceeded";
        case SpeechClientStatus_AudioOutputFailed:      return @"SpeechClientStatus_AudioOutputFailed";
        case SpeechClientStatus_MicrophoneInUse:        return @"SpeechClientStatus_MicrophoneInUse";
        case SpeechClientStatus_MicrophoneUnavailable:  return @"SpeechClientStatus_MicrophoneUnavailable";
        case SpeechClientStatus_MicrophoneStatusUnknown:return @"SpeechClientStatus_MicrophoneStatusUnknown";
        case SpeechClientStatus_InvalidArgument:        return @"SpeechClientStatus_InvalidArgument";
    }
    
    return [[NSString alloc] initWithFormat:@"Unknown error: %d\n", errorCode];
}

#pragma mark -转换识别率信息
NSString* ConvertSpeechRecoConfidenceEnumToString(Confidence confidence) {
    switch (confidence) {
        case SpeechRecoConfidence_None:
            return @"None";
            
        case SpeechRecoConfidence_Low:
            return @"Low";
            
        case SpeechRecoConfidence_Normal:
            return @"Normal";
            
        case SpeechRecoConfidence_High:
            return @"High";
    }
}

#pragma mark - 内存警告
- (void)didReceiveMemoryWarning{
    
#if !defined(TARGET_OS_MAC)
    [super didReceiveMemoryWarning];
#endif
    
}

@end
