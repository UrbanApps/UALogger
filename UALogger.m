//
//  UALogger.m
//  Ambiance
//
//  Created by Matt Coneybeare on 12/2/11.
//  Copyright (c) 2011 Urban Apps, LLC. All rights reserved.
//

#import "UALogger.h"

#import <asl.h>

@implementation UALogger

static NSString *_bundleName = nil;
static NSString *_userDefaultsKey = nil;

+ (NSString *)bundleName {
	if (_bundleName)
		_bundleName = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	
	return _bundleName;
}

+ (void)setBundleName:(NSString *)bundleName {
	_bundleName = bundleName;
}

+ (NSString *)userDefaultsKey {
	if (_userDefaultsKey)
		_userDefaultsKey = @"UALogger_LoggingEnabled";
	
	return _userDefaultsKey;
}

+ (void)setUserDefaultsKey:(NSString *)userDefaultsKey {
	_userDefaultsKey = userDefaultsKey;
}


+ (NSString *)applicationLog {
	NSMutableArray *logs = [NSMutableArray array];
	
	aslmsg q, m;
	int i;
	const char *key, *val;
	
	NSString *queryTerm = [self bundleName];
	
	q = asl_new(ASL_TYPE_QUERY);
	asl_set_query(q, ASL_KEY_SENDER, [queryTerm UTF8String], ASL_QUERY_OP_EQUAL);
	
	aslresponse r = asl_search(NULL, q);
	while (NULL != (m = aslresponse_next(r))) {
		NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
		
		for (i = 0; (NULL != (key = asl_key(m, i))); i++) {
			NSString *keyString = [NSString stringWithUTF8String:(char *)key];
			
			val = asl_get(m, key);
			
			NSString *string = [NSString stringWithUTF8String:val];
			[tmpDict setObject:string forKey:keyString];
		}
		
		NSString *message = [tmpDict objectForKey:@"Message"];
		if (message) {
			NSString *logString = [NSString stringWithFormat:
								   @"%@ %@",
								   [NSDate dateWithTimeIntervalSince1970:[[tmpDict objectForKey:@"Time"] intValue]],
								   message];
			[logs addObject:logString];
		}
								   
	}
	aslresponse_free(r);
	
	return [logs componentsJoinedByString:@"\n"];
}

+ (NSString *)methodNameWithPrettyFunction:(const char *)prettyFunction {
	NSString *function = [NSString stringWithCString:prettyFunction encoding:NSUTF8StringEncoding];
	
	NSString *methodName = nil;
	NSScanner *theScanner = [NSScanner scannerWithString:function];
	while ([theScanner isAtEnd] == NO) {
        [theScanner scanUpToString:@"[" intoString:NULL];
		[theScanner scanUpToString:@" " intoString:NULL];
		[theScanner scanUpToString:@"]" intoString:&methodName];
	}
	
	if (methodName.length) {
		return methodName;
	}
	
	return function;
}

+ (void)log:(NSString *)format, ... {
    @try {
#ifdef BUILD_MODE_APPSTORE // Only log on the app store if the debug setting is enabled in settings
		if ([NSUserDefaults standardUserDefaults] boolForKey:[self userDefaultsKey]) {
#endif
            if (format != nil) {
                va_list args;
                va_start(args, format);
                NSLogv(format, args);
                va_end(args);
            }
#ifdef BUILD_MODE_APPSTORE
        }
#endif
    }
    @catch (...) {
        NSLog(@"Caught an exception in UALogger"); 
    }
}


@end
