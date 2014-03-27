//
//  NTViewController.m
//  NTImageViewer
//
//  Created by Nicholas Tau on 3/27/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

#import "NTViewController.h"
#import "NTImageViewer.h"

@interface NTViewController ()

@end

@implementation NTViewController

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
    // Do any additional setup after loading the view.
    
    UIImageView  * imageView =
    [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"test.jpg"]];
    imageView.frame =CGRectMake(10, 10, 300, 300);
    imageView.userInteractionEnabled = YES;
    [self.view addSubview:imageView];
    
    UITapGestureRecognizer * tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(imageTapped:)];
    [imageView addGestureRecognizer:tapGesture];
}

-(void)imageTapped:(UITapGestureRecognizer*)gesture
{
    UIImageView * imageView = (UIImageView*)gesture.view;
    [[NTImageViewer sharedInstance] displayWithPlaceHolderImageView:imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
