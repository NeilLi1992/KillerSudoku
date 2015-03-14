//
//  HomeViewController.m
//  KillerSudoku
//
//  Created by 李泳 on 15/3/5.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import "HomeViewController.h"
#import "FUIButton.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "HelpViewController.h"
#import "FUIAlertView.h"
#import "PlayViewController.h"
#import "SoundPlayer.h"

#import "SolverViewController.h"
#import "SettingsViewController.h"
#import "HelpViewController.h"
#import "LoadTableViewController.h"

#import <AudioToolbox/AudioToolbox.h>

@interface HomeViewController () <FUIAlertViewDelegate>
@property (strong, nonatomic)FUIButton *playBtn;
@property (strong, nonatomic)FUIButton *solverBtn;
@property (strong, nonatomic)FUIButton *settingsBtn;
@property (strong, nonatomic)FUIButton *helpBtn;
@property (strong, nonatomic)UILabel *titleLbl;
@property (weak, nonatomic)FUIButton *debugBtn;
@property (strong, nonatomic)FUIAlertView *playChooseView;
@property (strong, nonatomic)SoundPlayer* soundPlayer;

@property (strong, nonatomic)NSMutableDictionary* savedGames;
@end

@implementation HomeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Check if user preference is set. Set default values if not.
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    if ([preferences stringForKey:@"cellStyle"] == nil) {
        // Need to set default settings
        [preferences setObject:@"color" forKey:@"cellStyle"];
        [preferences setBool:YES forKey:@"playSound"];
        [preferences setBool:YES forKey:@"playMusic"];
    }
    
    // Initialize a sound player
    self.soundPlayer = [[SoundPlayer alloc] init];
    if ([preferences boolForKey:@"playMusic"]) {
        [self.soundPlayer playMusic];
    }
    
    // Add buttons;
    [self addButtons];
    
    // Stylize with FlatUIKit
    [self stylize];
    
    // Prepare saved games
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent: @"savedGames.archive"];
    self.savedGames = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

    if (self.savedGames == nil) {
        self.savedGames = [[NSMutableDictionary alloc] init];
    }
    NSLog(@"Saved games: %@", self.savedGames);
          
    // Build the alert view for play choice
    self.playChooseView = [[FUIAlertView alloc] initWithTitle:@"Level"
                                                          message:@"Choose level or load stored games."
                                                         delegate:self cancelButtonTitle:@"Play Later"
                                                otherButtonTitles:@"Easy",@"Medium",@"Hard",@"Load",nil];
    
    
    self.playChooseView.titleLabel.textColor = [UIColor cloudsColor];
    self.playChooseView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    self.playChooseView.messageLabel.textColor = [UIColor cloudsColor];
    self.playChooseView.messageLabel.font = [UIFont flatFontOfSize:14];
    self.playChooseView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    self.playChooseView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    self.playChooseView.alertContainer.layer.cornerRadius = 3;
    self.playChooseView.alertContainer.layer.masksToBounds = YES;
    self.playChooseView.defaultButtonColor = [UIColor turquoiseColor];
    self.playChooseView.defaultButtonShadowColor = [UIColor greenSeaColor];
    self.playChooseView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    self.playChooseView.defaultButtonTitleColor = [UIColor whiteColor];
    
    FUIButton* loadBtn = (FUIButton*)[self.playChooseView.buttons objectAtIndex:4];
    loadBtn.buttonColor = [UIColor peterRiverColor];
    loadBtn.shadowColor = [UIColor belizeHoleColor];
    loadBtn.tintColor = [UIColor asbestosColor];
    [loadBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [loadBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];

    
    FUIButton* cancelBtn = (FUIButton*)[self.playChooseView.buttons objectAtIndex:self.playChooseView.cancelButtonIndex];
    cancelBtn.buttonColor = [UIColor cloudsColor];
    cancelBtn.shadowColor = [UIColor asbestosColor];
    cancelBtn.tintColor = [UIColor asbestosColor];
    [cancelBtn setTitleColor:[UIColor asbestosColor] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor asbestosColor] forState:UIControlStateHighlighted];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    // Hide navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)addButtons {
    CGFloat btnWidth = [UIScreen mainScreen].bounds.size.width * 0.6;
    CGFloat btnHeight = btnWidth / 5;
    CGFloat btnSep = btnHeight / 2;
    CGFloat btnX = [UIScreen mainScreen].bounds.size.width / 2 - btnWidth / 2;
    CGFloat btnY = [UIScreen mainScreen].bounds.size.height * 0.5;
    
    // Play button
    self.playBtn = [[FUIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnWidth, btnHeight)];
    [self.playBtn setTitle:@"Play" forState:UIControlStateNormal];
    self.playBtn.buttonColor = [UIColor turquoiseColor];
    self.playBtn.shadowColor = [UIColor greenSeaColor];
    self.playBtn.shadowHeight = 3.0f;
    self.playBtn.cornerRadius = 6.0f;
    self.playBtn.titleLabel.font = [UIFont boldFlatFontOfSize:20];
    [self.playBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.playBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [self.playBtn addTarget:self action:@selector(playBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playBtn];

    // Solver button
    self.solverBtn = [[FUIButton alloc] initWithFrame:CGRectMake(btnX, btnY + btnSep + btnHeight, btnWidth, btnHeight)];
    [self.solverBtn setTitle:@"Solver" forState:UIControlStateNormal];
    self.solverBtn.buttonColor = [UIColor turquoiseColor];
    self.solverBtn.shadowColor = [UIColor greenSeaColor];
    self.solverBtn.shadowHeight = 3.0f;
    self.solverBtn.cornerRadius = 6.0f;
    self.solverBtn.titleLabel.font = [UIFont boldFlatFontOfSize:20];
    [self.solverBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.solverBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [self.solverBtn addTarget:self action:@selector(solverBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.solverBtn];
    
    // Settings button
    self.settingsBtn = [[FUIButton alloc] initWithFrame:CGRectMake(btnX, btnY + 2 * (btnHeight + btnSep), btnWidth, btnHeight)];
    [self.settingsBtn setTitle:@"Settings" forState:UIControlStateNormal];
    self.settingsBtn.buttonColor = [UIColor turquoiseColor];
    self.settingsBtn.shadowColor = [UIColor greenSeaColor];
    self.settingsBtn.shadowHeight = 3.0f;
    self.settingsBtn.cornerRadius = 6.0f;
    self.settingsBtn.titleLabel.font = [UIFont boldFlatFontOfSize:20];
    [self.settingsBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.settingsBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [self.settingsBtn addTarget:self action:@selector(settingsBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingsBtn];
    
    // Help button
    self.helpBtn = [[FUIButton alloc] initWithFrame:CGRectMake(btnX, btnY + 3 * (btnHeight + btnSep), btnWidth, btnHeight)];
    [self.helpBtn setTitle:@"Help" forState:UIControlStateNormal];
    self.helpBtn.buttonColor = [UIColor turquoiseColor];
    self.helpBtn.shadowColor = [UIColor greenSeaColor];
    self.helpBtn.shadowHeight = 3.0f;
    self.helpBtn.cornerRadius = 6.0f;
    self.helpBtn.titleLabel.font = [UIFont boldFlatFontOfSize:20];
    [self.helpBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.helpBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [self.helpBtn addTarget:self action:@selector(helpBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.helpBtn];
    
    // Debug button
    self.debugBtn.buttonColor = [UIColor orangeColor];
    self.debugBtn.shadowColor = [UIColor pomegranateColor];
    self.debugBtn.shadowHeight = 3.0f;
    self.debugBtn.cornerRadius = 6.0f;
    self.debugBtn.titleLabel.font = [UIFont boldFlatFontOfSize:20];
    [self.debugBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.debugBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
}

- (void)stylize {
    // Stylize background
    self.view.backgroundColor = [UIColor concreteColor];
    
    // Stylize title
    [self.titleLbl setTextColor:[UIColor pomegranateColor]];
    self.titleLbl.font = [UIFont boldFlatFontOfSize:40];
}

# pragma mark - Action methods
- (void)playBtnPressed:(id)sender {
    [self.soundPlayer playButtonSound];
    
    FUIButton* loadBtn = (FUIButton*)[self.playChooseView.buttons objectAtIndex:4];
    if ([self.savedGames count] == 0) {
        loadBtn.enabled = false;
        [loadBtn setTitle:@"No saved games" forState:UIControlStateNormal];
    } else {
        loadBtn.enabled = true;
        [loadBtn setTitle:@"Load" forState:UIControlStateNormal];
    }
    
    [self.playChooseView show];
}

- (void)solverBtnPressed:(id)sender {
    [self.soundPlayer playButtonSound];
    SolverViewController* vc = [[SolverViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)settingsBtnPressed:(id)sender {
    [self.soundPlayer playButtonSound];
    SettingsViewController* vc = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)helpBtnPressed:(id)sender {
    [self.soundPlayer playButtonSound];
    HelpViewController* vc = [[HelpViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)debugBtnPressed:(id)sender {
    [self.soundPlayer playButtonSound];
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - Delegate methods
- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.soundPlayer playButtonSound];
    // Prepare to push the PlayViewController
    PlayViewController* playVC = [[PlayViewController alloc] init];
    LoadTableViewController* loadVC = [[LoadTableViewController alloc] initWithStyle:UITableViewStylePlain];
    switch (buttonIndex) {
        case 1:
            // Easy
            playVC.level = 0;
            [self.navigationController pushViewController:playVC animated:YES];
            break;
        case 2:
            // Medium
            playVC.level = 1;
            [self.navigationController pushViewController:playVC animated:YES];
            break;
        case 3:
            // Hard
            playVC.level = 2;
            [self.navigationController pushViewController:playVC animated:YES];
            break;
        case 4:
            // Push the load table view
            [loadVC prepareSavedGames:self.savedGames];
            [self.navigationController pushViewController:loadVC animated:YES];
            break;
        case 0:
            // Play later
            return;
        default:
            break;
    }
}

# pragma mark - Control center methods
-(void)saveArchive:(ArchiveWrapper*)archive {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent: @"savedGames.archive"];
    [self.savedGames setObject:archive forKey:archive.date];
    BOOL flag = [NSKeyedArchiver archiveRootObject:self.savedGames toFile:filePath];

    NSLog(@"Archive save status: %d", flag);
}

@end
