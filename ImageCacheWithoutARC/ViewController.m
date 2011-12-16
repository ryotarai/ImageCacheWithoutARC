//
//  ViewController.m
//  ImageCacheWithoutARC
//
//  Created by 荒井 良太 on 11/12/14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#import "ImageCache.h"

@implementation ViewController
@synthesize urlTextField = _urlTextField;
@synthesize imageView = _imageView;

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
  [self setImageView:nil];
  [self setUrlTextField:nil];
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc {
  [_imageView release];
  [_urlTextField release];
  [super dealloc];
}
- (IBAction)clearImageView:(id)sender {
  [_imageView setImage:nil];
}

- (IBAction)show:(id)sender {
  ImageCache *imageCache = [ImageCache sharedCache];
  NSURL *url = [NSURL URLWithString:_urlTextField.text];
  
  [imageCache
   imageAsyncForURL:url 
   completionBlock:^(UIImage *image) {
     [_imageView setImage:image];
   } 
   failureBlock:^(NSError *error) {
     NSLog(@"Failed");
  }];
}
@end
