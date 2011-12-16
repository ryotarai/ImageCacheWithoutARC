//
//  ViewController.h
//  ImageCacheWithoutARC
//
//  Created by 荒井 良太 on 11/12/14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (retain, nonatomic) IBOutlet UITextField *urlTextField;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)clearImageView:(id)sender;
- (IBAction)show:(id)sender;

@end
