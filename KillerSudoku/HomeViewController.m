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

@interface HomeViewController () <FUIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet FUIButton *playBtn;
@property (weak, nonatomic) IBOutlet FUIButton *solverBtn;
@property (weak, nonatomic) IBOutlet FUIButton *settingsBtn;
@property (weak, nonatomic) IBOutlet FUIButton *helpBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet FUIButton *debugBtn;
@property (strong, nonatomic) FUIAlertView *playChooseView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Check if user preference is set. Set default values if not.
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString* cellStyle = [preferences stringForKey:@"cellStyle"];
    if (cellStyle == nil) {
        [preferences setObject:@"color" forKey:@"cellStyle"];
    }
    
    // Stylize with FlatUIKit
    [self stylize];
    
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

- (void)stylize {
    // Stylize background
    self.view.backgroundColor = [UIColor concreteColor];
    
    // Stylize title
    [self.titleLbl setTextColor:[UIColor pomegranateColor]];
    self.titleLbl.font = [UIFont boldFlatFontOfSize:40];
    
    // Stylize buttons
    self.playBtn.buttonColor = [UIColor turquoiseColor];
    self.playBtn.shadowColor = [UIColor greenSeaColor];
    self.playBtn.shadowHeight = 3.0f;
    self.playBtn.cornerRadius = 6.0f;
    self.playBtn.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.playBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.playBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    self.solverBtn.buttonColor = [UIColor turquoiseColor];
    self.solverBtn.shadowColor = [UIColor greenSeaColor];
    self.solverBtn.shadowHeight = 3.0f;
    self.solverBtn.cornerRadius = 6.0f;
    self.solverBtn.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.solverBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.solverBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    self.settingsBtn.buttonColor = [UIColor turquoiseColor];
    self.settingsBtn.shadowColor = [UIColor greenSeaColor];
    self.settingsBtn.shadowHeight = 3.0f;
    self.settingsBtn.cornerRadius = 6.0f;
    self.settingsBtn.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.settingsBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.settingsBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    self.helpBtn.buttonColor = [UIColor turquoiseColor];
    self.helpBtn.shadowColor = [UIColor greenSeaColor];
    self.helpBtn.shadowHeight = 3.0f;
    self.helpBtn.cornerRadius = 6.0f;
    self.helpBtn.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.helpBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.helpBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    self.debugBtn.buttonColor = [UIColor orangeColor];
    self.debugBtn.shadowColor = [UIColor pomegranateColor];
    self.debugBtn.shadowHeight = 3.0f;
    self.debugBtn.cornerRadius = 6.0f;
    self.debugBtn.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.debugBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.debugBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
}

# pragma mark Action methods
- (IBAction)playBtnPressed:(id)sender {
    [self.playChooseView show];
}

- (IBAction)solverBtnPressed:(id)sender {
}

- (IBAction)settingsBtnPressed:(id)sender {
}

- (IBAction)helpBtnPressed:(id)sender {
}

- (IBAction)debugBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark Delegate methods
- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Prepare to push the PlayViewController
    PlayViewController* vc = [[PlayViewController alloc] init];
    switch (buttonIndex) {
        case 1:
            // Easy
            vc.level = 0;
            break;
        case 2:
            // Medium
            vc.level = 1;
            break;
        case 3:
            // Hard
            vc.level = 2;
            break;
        case 4:
            // Load
            vc.level = 0;   // Should actually do something else
            break;
        case 0:
            // Play later
            return;
        default:
            break;
    }
    
    // Push vc
    [self.navigationController pushViewController:vc animated:YES];
}

@end
