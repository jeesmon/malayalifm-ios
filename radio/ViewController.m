//
//  ViewController.m
//  radio
//
//  Created by jjacob on 12/11/13.
//  Copyright (c) 2013 jjacob. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Reachability.h"

@interface ViewController ()

@end

@implementation ViewController

NSString * const kStreamUrlString = @"http://knight.wavestreamer.com:2631/listen.pls?sid=1";
NSString * const kWebsiteUrlString = @"http://www.malayalifm.com";
NSString * const kMagzineUrlString = @"http://www.malayalimag.com";
NSString * const kFbUrlString = @"https://www.facebook.com/malayalifm";
NSString * const kFbSchemeUrl = @"fb://profile/248943741924235";
NSString * const kEmailString = @"voice@malayalifm.com";

bool isPlaying = false;
AVPlayer *player;
AVPlayerItem *playerItem;


- (void)viewDidLoad
{
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
    [self setupBackground];
    [self setupVolumeView];
    [self initSession];
    [self start];
}

-(void) setupBackground {
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if([self hasFourInchDisplay]) {
            [self.backgroundImageView setImage:[UIImage imageNamed:@"Background.png"]];
        }
        else {
            [self.backgroundImageView setImage:[UIImage imageNamed:@"Default.png"]];
        }
    }
    else {
        [self.backgroundImageView setImage:[UIImage imageNamed:@"Default-Portrait.png"]];
    }
}

- (BOOL)hasFourInchDisplay {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0);
}

-(void) setupVolumeView {
    NSLog(@"setupVolumeView");
}

-(void)initSession
{
    NSLog(@"initSession");
    // Registers this class as the delegate of the audio session.
    [[AVAudioSession sharedInstance] setDelegate: self];
    
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryError];
    if (setCategoryError) {
        NSLog(@"Error setting category! %@", [setCategoryError localizedDescription]);
    }
    
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    if (activationError) {
        NSLog(@"Could not activate audio session. %@", [activationError localizedDescription]);
    }
    
}

- (void)beginInterruption {
    NSLog(@"beginInterruption");
    
    [player pause];
}

- (void)endInterruptionWithFlags:(NSUInteger)flags {
    NSLog(@"endInterruptionWithFlags");
    
    if(flags == AVAudioSessionInterruptionOptionShouldResume) {
        [self start];
    }
}

- (void) viewDidAppear: (BOOL) animated {
    NSLog(@"viewDidAppear");
    
    [super viewDidAppear: animated];
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(beginReceivingRemoteControlEvents)]){
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self becomeFirstResponder];
    }
}

- (void) viewWillDisppear: (BOOL) animated {
    NSLog(@"viewWillDisppear");
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
    [super viewWillDisappear: animated];
}

- (BOOL) canBecomeFirstResponder {
    NSLog(@"canBecomeFirstResponder");
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)openWebsite:(id)sender {
    [self openInSafari:kWebsiteUrlString];
}

- (IBAction)openFb:(id)sender {
    NSURL *url = [NSURL URLWithString:kFbSchemeUrl];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    else {
        [self openInSafari:kFbUrlString];
    }
}

- (IBAction)sendEmail:(id)sender {
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setToRecipients:@[kEmailString]];
    [controller setSubject:@"Comments"];
    [controller setMessageBody:@"" isHTML:NO];
    if (controller) {
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (IBAction)openMagazine:(id)sender {
    [self openInSafari:kMagzineUrlString];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pressed:(id)sender {
    NSLog(@"pressed");
    
    if(isPlaying) {
        [self stop];
    }
    else {
        [self start];
    }
}

-(void) start {
    NSLog(@"start");
    
    if(player) {
        [self stop];
    }
    
    [self.action setEnabled:NO];

    NSURL *url = [[NSURL alloc] initWithString:kStreamUrlString];
    
    playerItem = [AVPlayerItem playerItemWithURL:url];
    [playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:0 context:nil];
    
    player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    
    [self showConnectMsg];
}

-(void) play {
    NSLog(@"play");
    
    /*
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    */
    
    [player play];
    isPlaying = TRUE;
    [self.action setImage:[UIImage imageNamed:[UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? @"stop.png" : @"stop-ipad.png"] forState:UIControlStateNormal];
    [self.action setEnabled:YES];
    
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"AlbumArt"]];
        
        [songInfo setObject:@"Malayali FM" forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
}

-(void) pause {
    NSLog(@"pause");
    
    [player pause];
    isPlaying = FALSE;
    [self hideConnectMsg];
    [self.action setImage:[UIImage imageNamed:[UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? @"play.png" : @"play-ipad.png"] forState:UIControlStateNormal];
}

-(void) stop {
    NSLog(@"stop");
    
    if(playerItem) {
        [playerItem removeObserver:self forKeyPath:@"status" context:nil];
        [playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:nil];
    }

    if(player) {
        [player pause];
    }
    
    playerItem = nil;
    player = nil;
    
    isPlaying = FALSE;
    [self hideConnectMsg];
    [self.action setImage:[UIImage imageNamed:[UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? @"play.png" : @"play-ipad.png"] forState:UIControlStateNormal];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    NSLog(@"observeValueForKeyPath");
    
    if(object == playerItem) {
        if([keyPath isEqualToString:@"status"]) {
            switch(playerItem.status)
            {
                case AVPlayerItemStatusFailed:
                    NSLog(@"player item status failed");
                    [self stop];
                    [self.action setEnabled:YES];
                    if(![self isReachable]) {
                        [self showNetworkErrorMsg];
                    }
                    break;
                case AVPlayerItemStatusReadyToPlay:
                    NSLog(@"player item status is ready to play");
                    [self play];
                    [self hideConnectMsg];
                    break;
                case AVPlayerItemStatusUnknown:
                    NSLog(@"player item status is unknown");
                    break;
            }
        }
        else if ([keyPath isEqualToString:@"playbackBufferEmpty"])
        {
            if (playerItem.playbackBufferEmpty)
            {
                NSLog(@"player item playback buffer is empty");
                if([self isReachable]) {
                    [self showBufferingMsg];
                    [self.action setEnabled:YES];
                }
                else {
                    [self stop];
                    [self showNetworkErrorMsg];
                    [self.action setEnabled:YES];
                }
            }
            else if(playerItem.playbackBufferFull) {
                [self hideConnectMsg];
            }
            else if(playerItem.playbackLikelyToKeepUp) {
                [self hideConnectMsg];
            }
        }
    }
}

- (BOOL) isReachable {
    Reachability* reachable = [Reachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus remoteHostStatus = [reachable currentReachabilityStatus];
    
    return remoteHostStatus != NotReachable;
}

- (void) hideConnectMsg {
     NSLog(@"hideConnectMsg");
    
    [self.connectMsg setHidden:TRUE];
}

- (void) showConnectMsg {
    NSLog(@"showConnectMsg");
    
    self.connectMsg.text = @"connecting ....";
    [self.connectMsg setHidden:FALSE];
}

- (void) showBufferingMsg {
    NSLog(@"showBufferingMsg");
    
    self.connectMsg.text = @"buffering ....";
    [self.connectMsg setHidden:FALSE];
}

- (void) showNetworkErrorMsg {
    NSLog(@"showNetworkErrorMsg");
    
    self.connectMsg.text = @"connection failed";
    [self.connectMsg setHidden:FALSE];
}

- (void) openInSafari: (NSString *) urlString {
    NSLog(@"openInSafari");
    
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - remote control events
- (void) remoteControlReceivedWithEvent: (UIEvent *) event {
    NSLog(@"remoteControlReceivedWithEvent");
    
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [self start];
                break;
            case UIEventSubtypeRemoteControlPause:
                [self pause];
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                isPlaying ? [self pause] : [self start];
                break;
            default:
                break;
        }
    }
}
@end
