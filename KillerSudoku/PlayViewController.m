//
//  PlayViewController.m
//  KillerSudoku
//
//  Created by 李泳 on 15/3/6.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import "PlayViewController.h"
#import "FUIButton.h"
#import "UIBarButtonItem+FlatUI.h"
#import "UINavigationBar+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "FUIAlertView.h"

@interface PlayViewController () <FUIAlertViewDelegate>

@end

@implementation PlayViewController

// Define some UI related parameters
CGFloat boardLength;
CGFloat cellLength;
CGFloat horiPadding;
CGFloat vertPadding;
CGFloat baseY;
CGFloat outerLineWidth;
CGFloat innerLineWidth;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialization
    self.isPlaying = true;
    horiPadding = 10;
    vertPadding = 10;
    boardLength = [UIScreen mainScreen].bounds.size.width - 2 * horiPadding;
    cellLength = boardLength / 9;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    baseY = statusBarHeight + navigationBarHeight;
    outerLineWidth = 2.0;
    innerLineWidth = 1.0;
    
    // Stylize and draw board
    [self stylize];
    [self drawBoard];
    
    
    NSLog(@"%d", self.level);
}

- (void)stylize {
    // Stylize background
    self.view.backgroundColor = [UIColor concreteColor];
    
    // Stylize navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor midnightBlueColor]];
    self.title = @"Play";
    [self.navigationItem.leftBarButtonItem configureFlatButtonWithColor:[UIColor peterRiverColor] highlightedColor:[UIColor belizeHoleColor] cornerRadius:3];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backBtnPressed)];
    [self.navigationItem.leftBarButtonItem configureFlatButtonWithColor:[UIColor peterRiverColor] highlightedColor:[UIColor belizeHoleColor] cornerRadius:3];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];
    
}

#pragma mark - Action methods
- (void)backBtnPressed {
    if (self.isPlaying) {
        // Build the alert view for play choice
        FUIAlertView* alertView = [[FUIAlertView alloc] initWithTitle:@"Sure"
                                                          message:@"Game unfinished, sure to exit?"
                                                         delegate:self cancelButtonTitle:@"Continue"
                                                otherButtonTitles:@"Exit now",@"Save game",nil];
        // Stylize the alert view
        alertView.titleLabel.textColor = [UIColor cloudsColor];
        alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
        alertView.messageLabel.textColor = [UIColor cloudsColor];
        alertView.messageLabel.font = [UIFont flatFontOfSize:14];
        alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
        alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
        alertView.alertContainer.layer.cornerRadius = 3;
        alertView.alertContainer.layer.masksToBounds = YES;
        alertView.defaultButtonColor = [UIColor turquoiseColor];
        alertView.defaultButtonShadowColor = [UIColor greenSeaColor];
        alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
        alertView.defaultButtonTitleColor = [UIColor whiteColor];
        
        FUIButton* cancelBtn = (FUIButton*)[alertView.buttons objectAtIndex:alertView.cancelButtonIndex];
        cancelBtn.buttonColor = [UIColor cloudsColor];
        cancelBtn.shadowColor = [UIColor asbestosColor];
        cancelBtn.tintColor = [UIColor asbestosColor];
        [cancelBtn setTitleColor:[UIColor asbestosColor] forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor asbestosColor] forState:UIControlStateHighlighted];
        
        // Show the alert view
        [alertView show];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark Drawing methods
- (void)drawBoard {
    // Draw frame of the board
    UIView* upper = [[UIView alloc] initWithFrame:CGRectMake(horiPadding, vertPadding+baseY, boardLength, outerLineWidth)];
    UIView* below = [[UIView alloc] initWithFrame:CGRectMake(horiPadding, vertPadding+boardLength+baseY, boardLength, outerLineWidth)];
    UIView* left = [[UIView alloc] initWithFrame:CGRectMake(horiPadding, vertPadding+baseY, outerLineWidth, boardLength)];
    UIView* right = [[UIView alloc] initWithFrame:CGRectMake(horiPadding+boardLength, vertPadding+baseY, outerLineWidth, boardLength+outerLineWidth)];
    
    upper.backgroundColor = [UIColor midnightBlueColor];
    below.backgroundColor = [UIColor midnightBlueColor];
    left.backgroundColor = [UIColor midnightBlueColor];
    right.backgroundColor = [UIColor midnightBlueColor];
    
    [self.view addSubview:upper];
    [self.view addSubview:below];
    [self.view addSubview:left];
    [self.view addSubview:right];
}

- (void)drawHint {
    
}

- (void)drawControl {
    
}

#pragma mark Delegate methods
-(void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1:
            // Exit now
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 2:
            // Save game
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 0:
            // Continue
            return;
        default:
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
