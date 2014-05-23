//
//  FASettingsViewController.h
//  anaconda-ios-demo
//
//  Created by Jeff McFadden on 5/22/14.
//  Copyright (c) 2014 ForgeApps. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString  *const kBaseURLPreferenceKey;

@class FASettingsViewController;

@protocol FASettingsViewControllerDelegate <NSObject>

- (void)settingsViewController:(FASettingsViewController *)settingsViewController didFinishWithBaseURL:(NSURL *)baseURL;

@end

@interface FASettingsViewController : UIViewController

@property (nonatomic) id<FASettingsViewControllerDelegate> delegate;

@end
