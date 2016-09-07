//
//  MSSpeechViewController.h
//  DllSpeechDemo
//
//  Created by zcdll on 16/9/5.
//  Copyright © 2016年 ZC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpeechSDK/SpeechRecognitionService.h>

@interface MSSpeechViewController : UIViewController <SpeechRecognitionProtocol>
{
    @public
    NSMutableString *textOnScreen;
    DataRecognitionClient *dataClient;
}
@property (weak, nonatomic) IBOutlet UITextView *logText;

@property (weak, nonatomic) IBOutlet UITextView *resultText;

@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (nonatomic, copy) MicrophoneRecognitionClient *micClient;

@property (nonatomic, copy) NSString *finalResult;

- (IBAction)StartButton:(id)sender;

- (NSString *)audioRecognitionWithMicCient;

@end
