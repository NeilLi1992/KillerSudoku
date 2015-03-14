//
//  SoundPlayer.h
//  KillerSudoku
//
//  Created by 李泳 on 15/3/13.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoundPlayer : NSObject

-(void)playButtonSound;
-(void)playSelectSound;
-(void)playDeselectSound;
-(void)playMusic;
-(void)stopMusic;
-(BOOL)isPlayingMusic;
@end
