//
//  ViewController.h
//  objCReflection
//
//  Created by nakano_michiharu on 2013/11/23.
//  Copyright (c) 2013年 nakanomi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *btnEnum;
@property (weak, nonatomic) IBOutlet UIButton *btnJson;


- (IBAction)onPushButton:(id)sender;

@end
