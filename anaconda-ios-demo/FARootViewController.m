//
//  FARootViewController.m
//  anaconda-ios-demo
//
//  Created by Jeff McFadden on 5/22/14.
//  Copyright (c) 2014 ForgeApps. All rights reserved.
//

#import "FARootViewController.h"
#import "FAPostListTableTableViewController.h"
#import "FASettingsViewController.h"

@interface FARootViewController ()

@property (nonatomic) FAPostListTableTableViewController *postListTableViewController;

@end

@implementation FARootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.postListTableViewController = [[FAPostListTableTableViewController alloc] initWithNibName:nil bundle:nil];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.postListTableViewController];
    
    [self addChildViewController:navigationController];
    [self.view addSubview:navigationController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
