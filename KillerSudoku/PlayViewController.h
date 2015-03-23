//
//  PlayViewController.h
//  KillerSudoku
//
//  Created by 李泳 on 15/3/6.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArchiveWrapper.h"
@interface PlayViewController : UIViewController
@property(nonatomic)NSInteger level;
@property(nonatomic)BOOL isPlaying;

- (void)loadGame:(ArchiveWrapper*)archive;
@end
