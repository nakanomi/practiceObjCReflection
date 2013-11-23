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
- (NSMutableDictionary*)getDictOfPropertyTypeFromObj:(NSObject*)obj;
- (NSMutableDictionary*)getDictOfMethodTypeFromObj:(NSObject*)obj;
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
/*
 辞書の中身
 key:	NSString*:	プロパティ名
 key-obj:	NSString*:	型情報
 */
- (NSMutableDictionary*)getDictOfPropertyTypeFromObj:(NSObject*)obj
{
	NSMutableDictionary* result = nil;
	objc_property_t *properties = nil;
	@try {
		unsigned int numOfProperties = 0;
		properties = class_copyPropertyList([obj class], &numOfProperties);
		result = [[NSMutableDictionary alloc] init];
		for (int i = 0; i < numOfProperties; i++) {
			objc_property_t property = properties[i];
			const char *propName = property_getName(property);
			const char *propType = property_getAttributes(property);
			NSString* strName = [[NSString alloc] initWithUTF8String:propName];
			NSString* strType = [[NSString alloc] initWithUTF8String:propType];
			[result setObject:strType forKey:strName];
		}
	}
	@catch (NSException *exception) {
		NSLog(@"%s:%@", __PRETTY_FUNCTION__, exception);
	}
	@finally {
		if (properties != nil) {
			free(properties);
		}
	}
	return result;
}
/*
辞書の中身
key:		NSString*:		メソッド名
key-obj:	NSMutableArray*:	引数型情報（おそらく３番目から）
 */
- (NSMutableDictionary*)getDictOfMethodTypeFromObj:(NSObject*)obj
{
	NSMutableDictionary* result = nil;
	Method* methods = nil;
	@try {
		unsigned int numOfMethods = 0;
		methods =  class_copyMethodList([obj class], &numOfMethods);
		result = [[NSMutableDictionary alloc] init];
		for (int i = 0; i < numOfMethods; i++) {
			char buffer[1024];
			SEL name = method_getName(methods[i]);
			NSString* strName = NSStringFromSelector(name);
			NSLog(@"%@", strName);
			//char *returnType = method_copyReturnType(methods[i]);
			//NSLog(@"return type is %s", returnType);
			//free(returnType);
			NSMutableArray* arrayArgs = [[NSMutableArray alloc] init];
			unsigned int numOfArgs = method_getNumberOfArguments(methods[i]);
			for (int j = 0; j < numOfArgs; j++) {
				method_getArgumentType(methods[i], j, buffer, 1024);
				NSLog(@"type of arg[%d] is %s", j, buffer);
				NSString* strArg = [[NSString alloc] initWithUTF8String:buffer];
				[arrayArgs addObject:strArg];
			}
			[result setObject:arrayArgs forKey:strName];
		}
	}
	@catch (NSException *exception) {
		NSLog(@"%s:%@", __PRETTY_FUNCTION__, exception);
	}
	@finally {
		if (methods != nil) {
			free(methods);
		}
	}
	return result;
}


- (IBAction)onPushButton:(id)sender
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	testClass* obj = [[testClass alloc] init];
	
	NSLog(@"%d", obj.width);
	if ([sender isEqual:self.btnEnum]) {
		{
			unsigned int numOfProperties = 0;
			objc_property_t *properties = class_copyPropertyList([obj class], &numOfProperties);
			for (int i = 0; i < numOfProperties; i++) {
				objc_property_t property = properties[i];
				const char *propName = property_getName(property);
				const char *propType = property_getAttributes(property);
				NSLog(@"property name:%s : type:%s", propName, propType);
				if (strcmp(propName, "width") == 0) {
					//どうやらIvarの取得は頭に"_"が必要？　あるいは実体が"_"つきだから？
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
		[obj setNgNameValue:1.0f];
		// 大文字と小文字の区別しか無いとき、値がセットされるのは片方だけ
		NSLog(@"%f", obj.ngNameValue);
		NSLog(@"%f", obj.NgNameValue);
	}
	else if ([sender isEqual:self.btnJson]) {
		NSBundle* bundle = [NSBundle mainBundle];
		NSString* path = [bundle pathForResource:@"isometric_grass_and_water"
										  ofType:@"json"];
		NSData* data = [[NSData alloc] initWithContentsOfFile:path];
		NSError* error = nil;
		id jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments
														   error:&error];
		if ([jsonObjects isKindOfClass:NSDictionary.class]) {
			NSLog(@"json dictionary");
			NSDictionary* dictJson = (NSDictionary*)jsonObjects;
			NSArray* arKeys = [dictJson allKeys];
			NSLog(@"%@", arKeys);
			NSMutableDictionary *dictPropertyType = [self getDictOfPropertyTypeFromObj:obj];
			NSMutableDictionary *dictMethodArgType = [self getDictOfMethodTypeFromObj:obj];
#if __has_feature(objc_arc)
			obj = nil;
			dictPropertyType = nil;
#else
			[obj release];
			[dictPropertyType release];
#endif
		}
	}
	
}


@end
