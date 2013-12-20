//
//  ViewController.h
//  radio
//
//  Created by jjacob on 12/11/13.
//  Copyright (c) 2013 jjacob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ViewController : UIViewController<AVAudioPlayerDelegate, AVAudioSessionDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *action;
@property (weak, nonatomic) IBOutlet UILabel *connectMsg;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
- (IBAction)openWebsite:(id)sender;
- (IBAction)openFb:(id)sender;
- (IBAction)sendEmail:(id)sender;
- (IBAction)openMagazine:(id)sender;

- (IBAction)pressed:(id)sender;

@end
