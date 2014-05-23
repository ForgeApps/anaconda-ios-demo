//
//  FAPostDetailViewController.m
//  anaconda-ios-demo
//
//  Created by Jeff McFadden on 5/22/14.
//  Copyright (c) 2014 ForgeApps. All rights reserved.
//

#import "FAPostDetailViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface FAPostDetailViewController ()

@property (nonatomic) NSDictionary *post;

@property (nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) IBOutlet UIImageView *imageView;


@end

@implementation FAPostDetailViewController

- (id)initWithPost:(NSDictionary *)post
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        _post = post;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.titleLabel.text = [self.post objectForKey:@"title"];
    [self.imageView setImageWithURL:[NSURL URLWithString:[self.post objectForKey:@"asset_url"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
