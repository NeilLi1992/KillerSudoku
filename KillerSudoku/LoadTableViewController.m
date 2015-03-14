//
//  LoadTableViewController.m
//  KillerSudoku
//
//  Created by 李泳 on 15/3/14.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import "LoadTableViewController.h"
#import "ArchiveWrapper.h"
#import "UIColor+FlatUI.h"
#import "UITableViewCell+FlatUI.h"
#import "UINavigationBar+FlatUI.h"
#import "UIBarButtonItem+FlatUI.h"
#import "SoundPlayer.h"
#import "FUIAlertView.h"
#import "UIFont+FlatUI.h"
#import "FUIButton.h"
#import "PlayViewController.h"

@interface LoadTableViewController ()
@property (strong, nonatomic)SoundPlayer* soundPlayer;
@property (strong, nonatomic)NSMutableDictionary* savedGames;
@property (strong, nonatomic)NSArray* allDates;
@property (strong, nonatomic)ArchiveWrapper* selectedArchive;
@end

static NSString * const FUITableViewControllerCellReuseIdentifier = @"FUITableViewControllerCellReuseIdentifier";

@implementation LoadTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialization
    self.soundPlayer = [[SoundPlayer alloc] init];
    
    self.title = @"Load";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:FUITableViewControllerCellReuseIdentifier];

    [self stylize];
}

- (void)prepareSavedGames:(NSMutableDictionary*)savedGames {
    self.savedGames = savedGames;
    self.allDates = [self.savedGames allKeys];
}

- (void)stylize {
    //Set the separator color
    self.tableView.separatorColor = [UIColor cloudsColor];
    
    //Set the background color
    self.tableView.backgroundColor = [UIColor concreteColor];
    self.tableView.backgroundView = nil;
    // Stylize navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor midnightBlueColor]];
    
    // Left bar button
    [self.navigationItem.leftBarButtonItem configureFlatButtonWithColor:[UIColor peterRiverColor] highlightedColor:[UIColor belizeHoleColor] cornerRadius:3];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backBtnPressed)];
    [self.navigationItem.leftBarButtonItem configureFlatButtonWithColor:[UIColor peterRiverColor] highlightedColor:[UIColor belizeHoleColor] cornerRadius:3];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];
    
    // Right bar button
    [self.navigationItem.rightBarButtonItem configureFlatButtonWithColor:[UIColor peterRiverColor] highlightedColor:[UIColor belizeHoleColor] cornerRadius:3];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Play"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(playBtnPressed)];
    [self.navigationItem.rightBarButtonItem configureFlatButtonWithColor:[UIColor peterRiverColor] highlightedColor:[UIColor belizeHoleColor] cornerRadius:3];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];
}

#pragma mark - Action methods
- (void)backBtnPressed {
    [self.soundPlayer playButtonSound];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)playBtnPressed {
    [self.soundPlayer playButtonSound];
    
    if (self.selectedArchive == nil) {
        FUIAlertView* noSelectionAlert = [[FUIAlertView alloc] initWithTitle:@"Oops" message:@"Need to select a game." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        noSelectionAlert.titleLabel.textColor = [UIColor cloudsColor];
        noSelectionAlert.titleLabel.font = [UIFont boldFlatFontOfSize:16];
        noSelectionAlert.messageLabel.textColor = [UIColor cloudsColor];
        noSelectionAlert.messageLabel.font = [UIFont flatFontOfSize:14];
        noSelectionAlert.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
        noSelectionAlert.alertContainer.backgroundColor = [UIColor midnightBlueColor];
        noSelectionAlert.alertContainer.layer.cornerRadius = 3;
        noSelectionAlert.alertContainer.layer.masksToBounds = YES;

        FUIButton* cancelBtn = (FUIButton*)[noSelectionAlert.buttons objectAtIndex:noSelectionAlert.cancelButtonIndex];
        cancelBtn.buttonColor = [UIColor cloudsColor];
        cancelBtn.shadowColor = [UIColor asbestosColor];
        cancelBtn.tintColor = [UIColor asbestosColor];
        [cancelBtn setTitleColor:[UIColor asbestosColor] forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor asbestosColor] forState:UIControlStateHighlighted];
        
        [noSelectionAlert show];
    } else {
        // Go to play
        PlayViewController* vc = [[PlayViewController alloc] init];
        [vc loadGame:self.selectedArchive];

        NSMutableArray* navArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
        [navArray replaceObjectAtIndex:[navArray count]-1 withObject:vc];
        [self.navigationController setViewControllers:navArray animated:YES];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.savedGames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIRectCorner corners = 0;
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:FUITableViewControllerCellReuseIdentifier];
    [cell configureFlatCellWithColor:[UIColor greenSeaColor]
                       selectedColor:[UIColor cloudsColor]
                     roundingCorners:corners];
    cell.separatorHeight = 5.;
    
    // Set the cell text
    ArchiveWrapper* archive = [self.savedGames objectForKey:[self.allDates objectAtIndex:indexPath.row]];
    NSDateFormatter * dateformatter = [[NSDateFormatter alloc]init];
    [dateformatter setLocale:[NSLocale currentLocale]];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString* cellText = [dateformatter stringFromDate:archive.date];
    
    cell.textLabel.text = cellText;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedArchive = [self.savedGames objectForKey:[self.allDates objectAtIndex:indexPath.row]];
}


@end
