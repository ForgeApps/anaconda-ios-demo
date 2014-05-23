//
//  FAPostListTableTableViewController.m
//  anaconda-ios-demo
//
//  Created by Jeff McFadden on 5/22/14.
//  Copyright (c) 2014 ForgeApps. All rights reserved.
//

#import "FAPostListTableTableViewController.h"
#import "FAPostDetailViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <FAAnaconda/FAAnaconda.h>

@interface FAPostListTableTableViewController ()

@property (nonatomic) NSArray *posts;

@property (nonatomic) FASettingsViewController *settingsViewController;

@property (nonatomic) NSURL *baseURL;

@property (nonatomic) UIImagePickerController *imagePickerController;

@property (copy) UIImage *imageToUpload;

@property (nonatomic) FAAnaconda *anaconda;
@property (nonatomic) NSProgress *uploadProgress;

@property (nonatomic) IBOutlet UIProgressView *uploadProgressView;

@property (nonatomic) IBOutlet UIView *tableHeaderView;

@end

@implementation FAPostListTableTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Posts";
    
    self.posts = @[];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPost:)];
    
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.settingsViewController = [[FASettingsViewController alloc] initWithNibName:nil bundle:nil];
    self.settingsViewController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshData];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.baseURL == nil) {
        NSString *baseURLInPreferences = [[NSUserDefaults standardUserDefaults] objectForKey:kBaseURLPreferenceKey];
        
        if (!baseURLInPreferences || [baseURLInPreferences isEqualToString:@""] ) {
            [self presentViewController:self.settingsViewController animated:YES completion:nil];
        }else{
            self.baseURL = [NSURL URLWithString:baseURLInPreferences];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshData
{
    if (self.baseURL == nil) {
        [self.refreshControl endRefreshing];
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/posts.json", self.baseURL];
    
    __weak FAPostListTableTableViewController *weakSelf = self;
    
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);

        weakSelf.posts = [responseObject objectForKey:@"posts"];
        [weakSelf.tableView reloadData];
        
        [self.refreshControl endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self.refreshControl endRefreshing];

    }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    // Configure the cell...
    NSDictionary *post = self.posts[indexPath.row];

    
    cell.textLabel.text = [post objectForKey:@"title"];
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:@"asset_url"]];
    
    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *post = self.posts[indexPath.row];
    FAPostDetailViewController *postDetailViewController = [[FAPostDetailViewController alloc] initWithPost:post];
    [self.navigationController pushViewController:postDetailViewController animated:YES];
}

#pragma mark SettingsViewController delegate

- (void)settingsViewController:(FASettingsViewController *)settingsViewController didFinishWithBaseURL:(NSURL *)baseURL
{
    self.baseURL = [baseURL copy];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark

- (IBAction)addPost:(id)sender
{
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    self.imagePickerController.delegate = self;
    
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.imageToUpload = [info objectForKey:UIImagePickerControllerEditedImage];
    if (self.imageToUpload == nil) {
        self.imageToUpload = [info objectForKey:UIImagePickerControllerOriginalImage];
    }

    self.anaconda = [[FAAnaconda alloc] initWithAPIBaseURL:self.baseURL];
    
    [self.anaconda getFileUploadCredentialsFromPath:@"posts/new.json" success:^(NSDictionary *credentials){
       
        NSLog( @"Credentials:\n%@", credentials );
        
        [self uploadImageWithCredentials:credentials];
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error ){
        
        NSLog( @"Failed getting credentials:\n%@", error );
        
    }];
}

- (void)uploadImageWithCredentials:(NSDictionary *)credentials
{
    NSMutableDictionary *uploadCredentials = [[[credentials objectForKey:@"post"] objectForKey:@"asset"] mutableCopy];
    
    [uploadCredentials setObject:[NSString stringWithFormat:@"%f.jpg", [NSDate timeIntervalSinceReferenceDate]] forKey:FAAnacondaCredentialsFileNameKey];
    
    NSData *imageData = UIImageJPEGRepresentation(self.imageToUpload, 0.8);
    
    self.uploadProgress = [[NSProgress alloc] init];
    
    self.uploadProgressView.progress = 0;
    self.tableView.tableHeaderView = self.tableHeaderView;
    
    [self.uploadProgress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self.anaconda uploadFileData:imageData withUploadCredentials:uploadCredentials progress:self.uploadProgress success: ^(NSDictionary *anacondaKeysForObject, NSURLResponse *response, id responseObject){
        
        NSLog( @"Upload success!\n%@", responseObject );
        
        [self.tableHeaderView removeFromSuperview];
        self.tableHeaderView = nil;
        
        [self createNewPost:anacondaKeysForObject];
        
    }failure:^(NSError *error, NSURLResponse *response, id responseObject){
        
        NSLog( @"Upload failure!\n%@", error );

        [self.tableHeaderView removeFromSuperview];
        self.tableHeaderView = nil;
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.uploadProgressView.progress = self.uploadProgress.fractionCompleted;
        });
    }
}

- (void)createNewPost:(NSDictionary *)anacondaKeys
{
    //[:title, :asset_filename, :asset_file_path, :asset_size, :asset_original_filename, :asset_stored_privately, :asset_type]


    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/posts.json", self.baseURL];
    
    __weak FAPostListTableTableViewController *weakSelf = self;
    
    NSDictionary *parameters = @{@"title": [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]],
                                 @"asset_filename" : [anacondaKeys objectForKey:@"filename"],
                                 @"asset_file_path" : [anacondaKeys objectForKey:@"file_path"],
                                 @"asset_size" : [anacondaKeys objectForKey:@"size"],
                                 @"asset_original_filename" : [anacondaKeys objectForKey:@"original_filename"],
                                 @"asset_stored_privately" : @"true",
                                 @"asset_type" : @"image"
                                 };
    
    [manager POST:urlString parameters:@{@"post":parameters} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);

        [weakSelf refreshData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
}

@end
