//
//  FASettingsViewController.m
//  anaconda-ios-demo
//
//  Created by Jeff McFadden on 5/22/14.
//  Copyright (c) 2014 ForgeApps. All rights reserved.
//

#import "FASettingsViewController.h"

NSString  *const kBaseURLPreferenceKey = @"baseurl";


@interface FASettingsViewController ()

@property (nonatomic) IBOutlet UITextField *baseURLTextField;

@end

@implementation FASettingsViewController

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
    
    self.baseURLTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:kBaseURLPreferenceKey];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:self.baseURLTextField.text forKey:kBaseURLPreferenceKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSURL *url = nil;
    
    if( self.baseURLTextField.text && ![self.baseURLTextField.text isEqualToString:@""] ){
        url = [NSURL URLWithString:self.baseURLTextField.text];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(settingsViewController:didFinishWithBaseURL:)]) {
        [self.delegate settingsViewController:self didFinishWithBaseURL:url];
    }
}


@end
