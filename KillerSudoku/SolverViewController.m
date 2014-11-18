//
//  SolverViewController.m
//  KillerSudoku
//
//  Created by 李泳 on 14/11/11.
//  Copyright (c) 2014年 yongli1992. All rights reserved.
//

#import "SolverViewController.h"

@interface SolverViewController ()
@property(nonatomic, strong)NSSet* boardDict;
@property(nonatomic, strong)NSMutableArray* boardCells;
@property(strong, nonatomic) IBOutlet UIView *gv;
@property(strong, nonatomic)NSMutableArray* selectedCells;
@property(strong, nonatomic)UIPanGestureRecognizer* gestureRecognizer;
@end

@implementation SolverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set it to support swipe gesture
    self.gv.userInteractionEnabled = YES;
    self.gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    // Only one finger swipe is allowed
    self.gestureRecognizer.minimumNumberOfTouches = 1;
    self.gestureRecognizer.maximumNumberOfTouches = 1;
    [self.gv addGestureRecognizer:self.gestureRecognizer];
    
    self.selectedCells = [[NSMutableArray alloc] init];
    
    [self drawBoardLines];
    [self drawBoardCells];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialize {
    self.boardDict = [[NSSet alloc] init];
    
}

/*!
 * Draw the board lines
 */
- (void)drawBoardLines {
    
    // add horizontal lines
    for (int i = 0; i < 4; i++) {
        UIView* horiLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 20 + i * cellLength * 3 + baseY, self.view.bounds.size.width, 2)];
        horiLineView.backgroundColor = [UIColor blackColor];
        // Set a high z position so it remains above the cells
        horiLineView.layer.zPosition = 10;
        [self.view addSubview:horiLineView];
    }
    
    // add vertical lines
    for (int i = 0; i < 3; i++) {
        UIView* vertiLineView = [[UIView alloc] initWithFrame:CGRectMake(i * cellLength * 3, 20 + baseY, 2, self.view.bounds.size.width)];
        vertiLineView.backgroundColor = [UIColor blackColor];
        vertiLineView.layer.zPosition = 10;
        [self.view addSubview:vertiLineView];
    }
    UIView* vertiLineView = [[UIView alloc] initWithFrame:CGRectMake(3 * cellLength * 3 - 2, 20 + baseY, 2, self.view.bounds.size.width)];
    vertiLineView.backgroundColor = [UIColor blackColor];
    vertiLineView.layer.zPosition = 10;
    [self.view addSubview:vertiLineView];
    
}


/*!
 * Draw the board cells
 */
- (void)drawBoardCells {
    [self.boardCells removeAllObjects];
    float cellLength = 320.0f / 9;
    // colorMatrix stores the color representatiion for coloring all the cells
    
    for (int i = 0; i < 9; i++) {
        [self.boardCells addObject:[[NSMutableArray alloc] init]];
        for (int j = 0; j < 9; j++) {
            // Generate a cellView and set it properly
            UIView* cellView = [[UIView alloc] initWithFrame:CGRectMake(j * cellLength, 20 + i * cellLength + baseY, cellLength, cellLength)];
            cellView.layer.borderColor = [UIColor blackColor].CGColor;
            cellView.layer.borderWidth = 0.5f;
            
            // Save it in the boardCells array
            [[self.boardCells objectAtIndex:i] addObject:cellView];
            [self.view addSubview:cellView];
        }
    }
    
}

#pragma mark Gesture handler
- (void)handleSwipe:(UIPanGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        // The selection starts
        NSLog(@"Selection started!\n");
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        // The selection ended
        NSLog(@"Selection ended, selected cells:%@\n", self.selectedCells);
        
    } else {
        CGPoint location = [gesture locationInView:self.gv];
        NSLog(@"Location: %g, %g\n", location.x, location.y);
        
        // Check the selection is within the board
        if (location.y < baseY + 22) {
            NSLog(@"Gesture out of board, recognizer reset.\n");
            self.gestureRecognizer.enabled = NO;
            self.gestureRecognizer.enabled = YES;
        }
    }
}
@end
