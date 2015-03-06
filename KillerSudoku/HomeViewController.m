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

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet FUIButton *playBtn;
@property (weak, nonatomic) IBOutlet FUIButton *solverBtn;
@property (weak, nonatomic) IBOutlet FUIButton *settingsBtn;
@property (weak, nonatomic) IBOutlet FUIButton *helpBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet FUIButton *debugBtn;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self stylize];
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

@end
