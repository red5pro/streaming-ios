//
//  DetailViewController.h
//  R5ProObjectiveCExamples
//
//  Created by David Heimann on 6/5/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate>

@property(nonatomic, readonly) BOOL shouldAutorotate;
@property(nonatomic, readonly) UIInterfaceOrientationMask supportedInterfaceOrientations;
@property (strong, nonatomic) NSDictionary *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

