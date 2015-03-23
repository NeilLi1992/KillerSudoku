//
//  SoundPlayer.m
//  KillerSudoku
//
//  Created by 李泳 on 15/3/13.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import "SoundPlayer.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundPlayer()
@end

@implementation SoundPlayer
static SoundPlayer* sharedPlayer = nil;

BOOL hasInited;
SystemSoundID buttonSound;
SystemSoundID selectSound;
SystemSoundID deselectSound;
SystemSoundID bgdMusc;
AVAudioPlayer* audioPlayer;
NSUserDefaults* preferences;

-(id)init {
    if (sharedPlayer != nil) {
        return sharedPlayer;
    }
    
    NSLog(@"Going to init a sound player");
    self = [super init];
    
    preferences = [NSUserDefaults standardUserDefaults];
    
    // Load button sound
    NSURL* btnURL = [[NSBundle mainBundle] URLForResource:@"buttonSound" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)btnURL, &buttonSound);
    
    // Load select sound
    NSURL* selectURL = [[NSBundle mainBundle] URLForResource:@"selectSound" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)selectURL, &selectSound);
    
    // Load deselect sound
    NSURL* deselectURL = [[NSBundle mainBundle] URLForResource:@"deselectSound" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)deselectURL, &deselectSound);
    
    // Load background music
    NSURL* musicURL = [[NSBundle mainBundle] URLForResource:@"silentNight" withExtension:@"mp3"];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
    audioPlayer.numberOfLoops = -1;

    sharedPlayer = self;
    return self;
}

-(void)playButtonSound {
    if ([preferences boolForKey:@"playSound"]) {
        AudioServicesPlaySystemSound(buttonSound);
    }
}

-(void)playSelectSound {
    if ([preferences boolForKey:@"playSound"]) {
        AudioServicesPlaySystemSound(selectSound);
    }
}

-(void)playDeselectSound {
    if ([preferences boolForKey:@"playSound"]) {
        AudioServicesPlaySystemSound(deselectSound);
    }
}

-(void)playMusic {
    [audioPlayer play];
}

-(void)stopMusic {
    [audioPlayer stop];
}

-(BOOL)isPlayingMusic {
    return audioPlayer.isPlaying;
}

@end
