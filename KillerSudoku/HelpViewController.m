//
//  HelpViewController.m
//  KillerSudoku
//
//  Created by 李泳 on 15/3/6.
//  Copyright (c) 2015年 yongli1992. All rights reserved.
//

#import "HelpViewController.h"
#import "FUIButton.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "UIBarButtonItem+FlatUI.h"
#import "UINavigationBar+FlatUI.h"
#import "SoundPlayer.h"

@interface HelpViewController () <UIScrollViewDelegate>
@property(strong, nonatomic)SoundPlayer* soundPlayer;
@property(nonatomic)NSInteger pageNum;

// View related properties
@property(strong, nonatomic)UIScrollView* scrollView;
@property(strong, nonatomic)UIPageControl* pageControl;

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.soundPlayer = [[SoundPlayer alloc] init];
    
    // Initialization
    self.pageNum = 3;
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * self.pageNum, CGRectGetHeight(self.scrollView.frame));
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView.delegate = self;
    
    [self.view addSubview:self.scrollView];
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.frame = CGRectMake(0, CGRectGetHeight(self.scrollView.frame) - 80,  CGRectGetWidth(self.scrollView.frame), 80);
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor cloudsColor];
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = self.pageNum;
    self.pageControl.hidesForSinglePage = YES;
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.pageControl];
    
    [self loadViews];
    
    
    // Do any additional setup after loading the view.
    [self stylize];
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

- (void)loadViews {
    // 1st view
    UIView* firstView = [[UIView alloc] init];
    CGRect frame = self.scrollView.frame;
    frame.origin.x = CGRectGetWidth(frame) * 0;
    frame.origin.y = 0;
    firstView.frame = frame;
    firstView.backgroundColor = [UIColor concreteColor];
    [self.scrollView addSubview:firstView];
    
    
    // 2nd view
    UIView* secondView = [[UIView alloc] init];
    frame.origin.x = CGRectGetWidth(frame) * 1;
    secondView.frame = frame;
    secondView.backgroundColor = [UIColor concreteColor];
    [self.scrollView addSubview:secondView];
    
    // 3rd view
    UIView* thirdView = [[UIView alloc] init];
    frame.origin.x = CGRectGetWidth(frame) * 2;
    frame.origin.y = 0;
    thirdView.frame = frame;
    thirdView.backgroundColor = [UIColor concreteColor];
    [self.scrollView addSubview:thirdView];
}

# pragma mark - Action methods
- (void)backBtnPressed {
    [self.soundPlayer playButtonSound];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)changePage:(id*)sender {
    
}

# pragma mark - Delegate methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // Find which page we are on
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
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
