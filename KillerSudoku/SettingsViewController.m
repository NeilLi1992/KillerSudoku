//
//  SettingsViewController.m
//  KillerSudoku
//
//  Created by 李泳 on 15/3/8.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import "SettingsViewController.h"
#import "FUIButton.h"
#import "UIColor+FlatUI.h"
#import "UIBarButtonItem+FlatUI.h"
#import "UINavigationBar+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "FUISegmentedControl.h"
#import "FUISwitch.h"
#import "SoundPlayer.h"

@interface SettingsViewController ()
@property(strong, nonatomic)NSUserDefaults* preferences;
@property(strong, nonatomic)SoundPlayer* soundPlayer;
@end

// View related parameters
CGFloat screenWidth;
CGFloat sepHeight;
CGFloat leftPadding;
CGFloat rightPadding;
CGFloat inlinePadding;
CGFloat itemTextWidth;
CGFloat itemTextHeight;
CGFloat baseY;

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialization
    self.preferences = [NSUserDefaults standardUserDefaults];
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    sepHeight = 20.0f;
    leftPadding = 20.0f;
    rightPadding = 20.0f;
    inlinePadding = 10.0f;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    baseY = statusBarHeight + navigationBarHeight;
    itemTextWidth = 100.0f;
    itemTextHeight = 40.0f;
    self.soundPlayer = [[SoundPlayer alloc] init];
    
    // Stylize
    [self stylize];
    
    // Setting 1: board style
    FUIButton* boardStyleBtn = [[FUIButton alloc] initWithFrame:CGRectMake(leftPadding, baseY + sepHeight, itemTextWidth, itemTextHeight)];
    boardStyleBtn.buttonColor = [UIColor orangeColor];
    boardStyleBtn.cornerRadius = 6.0f;
    boardStyleBtn.titleLabel.font = [UIFont boldFlatFontOfSize:14];
    [boardStyleBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [boardStyleBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [boardStyleBtn setTitle:@"Board Style" forState:UIControlStateNormal];
    boardStyleBtn.enabled = NO;
    [self.view addSubview:boardStyleBtn];
    
    NSArray* itemArray = [NSArray arrayWithObjects:@"Color", @"Line", nil];
    NSInteger segWidth = 150.0f;
    FUISegmentedControl* boardStyleSegCtl = [[FUISegmentedControl alloc] initWithItems:itemArray];
    boardStyleSegCtl.frame = CGRectMake(screenWidth - rightPadding - segWidth, baseY + sepHeight, segWidth, itemTextHeight);
    [boardStyleSegCtl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    boardStyleSegCtl.selectedFont = [UIFont boldFlatFontOfSize:16];
    boardStyleSegCtl.selectedFontColor = [UIColor cloudsColor];
    boardStyleSegCtl.deselectedFont = [UIFont flatFontOfSize:16];
    boardStyleSegCtl.deselectedFontColor = [UIColor cloudsColor];
    boardStyleSegCtl.selectedColor = [UIColor amethystColor];
    boardStyleSegCtl.deselectedColor = [UIColor silverColor];
    boardStyleSegCtl.dividerColor = [UIColor midnightBlueColor];
    boardStyleSegCtl.cornerRadius = 5.0;
    boardStyleSegCtl.selectedSegmentIndex = ([[self.preferences objectForKey:@"cellStyle"] isEqualToString:@"Color"]) ? 0 : 1;
    [self.view addSubview:boardStyleSegCtl];
    
    // Setting 2: effect sound
    FUIButton* soundBtn = [[FUIButton alloc] initWithFrame:CGRectMake(leftPadding, baseY + 2 * sepHeight + itemTextHeight, itemTextWidth, itemTextHeight)];
    soundBtn.buttonColor = [UIColor orangeColor];
    soundBtn.cornerRadius = 6.0f;
    soundBtn.titleLabel.font = [UIFont boldFlatFontOfSize:14];
    [soundBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [soundBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [soundBtn setTitle:@"Effect Sound" forState:UIControlStateNormal];
    soundBtn.enabled = NO;
    [self.view addSubview:soundBtn];
    
    NSInteger switchWidth = 80.0f;
    FUISwitch* soundSwitch = [[FUISwitch alloc] initWithFrame:CGRectMake(screenWidth - rightPadding - switchWidth, baseY + 2 * sepHeight + itemTextHeight, switchWidth, itemTextHeight)];
    [soundSwitch addTarget:self action:@selector(soundSwitched:) forControlEvents:UIControlEventValueChanged];
    soundSwitch.onColor = [UIColor turquoiseColor];
    soundSwitch.offColor = [UIColor cloudsColor];
    soundSwitch.onBackgroundColor = [UIColor midnightBlueColor];
    soundSwitch.offBackgroundColor = [UIColor silverColor];
    soundSwitch.offLabel.font = [UIFont boldFlatFontOfSize:14];
    soundSwitch.onLabel.font = [UIFont boldFlatFontOfSize:14];
    [soundSwitch setOn:[self.preferences boolForKey:@"playSound"] animated:NO];
    [self.view addSubview:soundSwitch];
    
    // Setting 3: music
    FUIButton* musicBtn = [[FUIButton alloc] initWithFrame:CGRectMake(leftPadding, baseY + 3 * sepHeight + 2 * itemTextHeight, itemTextWidth, itemTextHeight)];
    musicBtn.buttonColor = [UIColor orangeColor];
    musicBtn.cornerRadius = 6.0f;
    musicBtn.titleLabel.font = [UIFont boldFlatFontOfSize:14];
    [musicBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [musicBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [musicBtn setTitle:@"Music" forState:UIControlStateNormal];
    musicBtn.enabled = NO;
    [self.view addSubview:musicBtn];
    
    FUISwitch* musicSwitch = [[FUISwitch alloc] initWithFrame:CGRectMake(screenWidth - rightPadding - switchWidth, baseY + 3 * sepHeight + 2 * itemTextHeight, switchWidth, itemTextHeight)];
    [musicSwitch addTarget:self action:@selector(musicSwitched:) forControlEvents:UIControlEventValueChanged];
    musicSwitch.onColor = [UIColor turquoiseColor];
    musicSwitch.offColor = [UIColor cloudsColor];
    musicSwitch.onBackgroundColor = [UIColor midnightBlueColor];
    musicSwitch.offBackgroundColor = [UIColor silverColor];
    musicSwitch.offLabel.font = [UIFont boldFlatFontOfSize:14];
    musicSwitch.onLabel.font = [UIFont boldFlatFontOfSize:14];
    [musicSwitch setOn:[self.preferences boolForKey:@"playMusic"] animated:NO];
    [self.view addSubview:musicSwitch];

}

- (void)stylize {
    // Stylize background
    self.view.backgroundColor = [UIColor concreteColor];
    
    // Stylize navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor midnightBlueColor]];
    [self.navigationItem.leftBarButtonItem configureFlatButtonWithColor:[UIColor peterRiverColor] highlightedColor:[UIColor belizeHoleColor] cornerRadius:3];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backBtnPressed)];
    [self.navigationItem.leftBarButtonItem configureFlatButtonWithColor:[UIColor peterRiverColor] highlightedColor:[UIColor belizeHoleColor] cornerRadius:3];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];

}

# pragma makr - Action methods
- (void)backBtnPressed {
    [self.soundPlayer playButtonSound];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)segmentChanged:(FUISegmentedControl*)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self.preferences setObject:@"Color" forKey:@"cellStyle"];
            break;
        case 1:
            [self.preferences setObject:@"Line" forKey:@"cellStyle"];
            break;
        default:
            break;
    }
}

- (void)soundSwitched:(FUISwitch*)sender {
    if ([sender isOn]) {
        [self.preferences setBool:YES forKey:@"playSound"];
    } else {
        [self.preferences setBool:NO forKey:@"playSound"];
    }
}

- (void)musicSwitched:(FUISwitch*)sender {
    if ([sender isOn]) {
        [self.preferences setBool:YES forKey:@"playMusic"];
        [self.soundPlayer playMusic];
    } else {
        [self.preferences setBool:NO forKey:@"playMusic"];
        [self.soundPlayer stopMusic];
    }
}

# pragma mark - Delegate methods

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
