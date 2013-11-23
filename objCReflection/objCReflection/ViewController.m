//
//  ViewController.m
//  objCReflection
//
//  Created by nakano_michiharu on 2013/11/23.
//  Copyright (c) 2013年 nakanomi. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/objc-class.h>

#import "ViewController.h"
#import "testClass.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onPushButton:(id)sender
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	testClass* obj = [[testClass alloc] init];
	NSLog(@"%d", obj.width);
	{
		unsigned int numOfProperties = 0;
		objc_property_t *properties = class_copyPropertyList([obj class], &numOfProperties);
		for (int i = 0; i < numOfProperties; i++) {
			objc_property_t property = properties[i];
			const char *propName = property_getName(property);
			const char *propType = property_getAttributes(property);
			NSLog(@"property name:%s : type:%s", propName, propType);
			if (strcmp(propName, "width") == 0) {
				//どうやら頭に"_"が必要？
				Ivar iVar = class_getInstanceVariable([obj class], "_width");
#if __has_feature(objc_arc)
				void *pDummy = (void*)4;
				object_setIvar(obj, iVar, (__bridge id)pDummy);
#else
				// ARCを使うと、idにキャストできない
				object_setIvar(obj, iVar, (id)4);
#endif
				NSLog(@"width:%d", obj.width);
			}
		}
		free(properties);
	}
	
	unsigned int numOfMethods = 0;
	Method* methods = class_copyMethodList([obj class], &numOfMethods);
	for (int i = 0; i < numOfMethods; i++) {
		char buffer[1024];
		SEL name = method_getName(methods[i]);
		NSLog(@"%@", NSStringFromSelector(name));
		char *returnType = method_copyReturnType(methods[i]);
		NSLog(@"return type is %s", returnType);
		free(returnType);
		unsigned int numOfArgs = method_getNumberOfArguments(methods[i]);
		for (int j = 0; j < numOfArgs; j++) {
			method_getArgumentType(methods[i], j, buffer, 1024);
			NSLog(@"type of arg[%d] is %s", j, buffer);
		}
	}
	free(methods);
	[obj setFValue:1.0f];
	// 値がセットされるのは片方だけ
	NSLog(@"%f", obj.fValue);
	NSLog(@"%f", obj.FValue);
	
	obj = nil;
}


@end
