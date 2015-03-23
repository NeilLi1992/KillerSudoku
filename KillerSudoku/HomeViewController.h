//
//  HomeViewController.h
//  KillerSudoku
//
//  Created by 李泳 on 15/3/5.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArchiveWrapper.h"
@interface HomeViewController : UIViewController

-(void)saveArchive:(ArchiveWrapper*)archive;
-(void)deleteArchiveWithDate:(NSDate*)date;
@end
