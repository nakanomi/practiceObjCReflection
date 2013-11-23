//
//  ViewController.h
//  objCReflection
//
//  Created by nakano_michiharu on 2013/11/23.
//  Copyright (c) 2013年 nakanomi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
#if __has_feature(objc_arc)

@property (weak, nonatomic) IBOutlet UIButton *btnEnum;
@property (weak, nonatomic) IBOutlet UIButton *btnJson;
#else
@property (retain, nonatomic) IBOutlet UIButton *btnEnum;
@property (retain, nonatomic) IBOutlet UIButton *btnJson;
#endif


- (IBAction)onPushButton:(id)sender;

@end
