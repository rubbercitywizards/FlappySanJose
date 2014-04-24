//
//  RCWViewController.m
//  FlappySanJose
//
//  Created by Jonathan on 4/24/14.
//  Copyright (c) 2014 Rubber City Wizards. All rights reserved.
//

#import "RCWViewController.h"
#import "RCWMyScene.h"

@implementation RCWViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [RCWMyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

@end
