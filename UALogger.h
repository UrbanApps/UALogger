//
//  UALogger.h
//  Ambiance
//
//  Created by Matt Coneybeare on 12/2/11.
//  Copyright (c) 2011 Urban Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UALogger : NSObject

+ (NSString *)bundleName;									// Default is CFBundleName
+ (void)setBundleName:(NSString *)bundleName;

+ (NSString *)userDefaultsKey;								// Default is UALogger_LoggingEnabled
+ (void)setUserDefaultsKey:(NSString *)userDefaultsKey;

+ (NSString *)applicationLog;

+ (NSString *)methodNameWithPrettyFunction:(const char *)prettyFunction;

+ (void)log:(NSString *)format, ...;



@end
