//
//  testClass.h
//  testIVar
//
//  Created by nakano_michiharu on 2013/11/22.
//  Copyright (c) 2013年 nakanomi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface testClass : NSObject

@property (assign, nonatomic) int width;
@property (assign, nonatomic) double dValue;
@property (assign, nonatomic) NSString* strValue;
@property (assign, nonatomic) NSNumber* nsNumber;
// 良くない名前の例：名前の一文字目が大文字と小文字というだけの違いになっている
@property (assign, nonatomic) float ngNameValue;
@property (assign, nonatomic) float NgNameValue;
@end
