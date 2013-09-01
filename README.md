# UALogger

UALogger is a logging tool for iOS and Mac apps. It allows you to customize the log format, customize when to log to the console, and allows collection of the entire recent console log for your application. It includes the `UALogger` class and class methods, and a few handy macros.


---
### Installation


    pod 'UALogger'
    
Then, simply place this line in your `prefix.pch` file to access the logger from all of your source files.

    #import <UALogger.h>
    


---
### Usage

##### Macros

`UALogPlain` logs to the console just like NSLog.
    
    EX: UALogPlain logs to the console just like NSLog.    
    
`UALogBasic` logs as well, but also logs the file name and line number.

    EX: <UAViewController.m:27> UALogBasic logs as well...
    
`UALogFull` logs the calling object (self), the file name, the line number and the method name.

    EX: <0xb26b730 UAViewController.m:28 (viewDidLoad)> UALogFull logs the...


`UALog` is a short synonym for UALogPlain.

One easy way to use `UALogger` is to do a project-wide find and replace for `NSLog`, and change it to `UALog`.

    UALog(@"This used to be an NSLog()");
    
	

#### Variables
	
Because `UALog` works just like `NSLog`, you can pass in variables:
 
    UALog(@"Because UALog works just like NSLog, you can %@ in %@:", @"pass", @"variables");
	UALog(@" - %@", self);
	UALog(@" - %d", arc4random() % 99);
	UALog(@" - %.6f", M_PI);
	UALog(@" - %@.", [NSDate date]);
	
	Because UALog works just like NSLog, you can pass in variables:
	 - <UAViewController: 0xb26b730>
	 - 67
	 - 3.141593
	 - 2013-09-01 20:23:03 +0000.
	
Just like NSLog, you can pass in multiple variables too:

	UALog(@"Just like NSLog, you can pass in multiple variables too:");
	UALog(@" - %.3f * %.3f = %.6f", M_PI_2, M_PI_4, M_PI_2 * M_PI_4);
	UALog(@" - One, %@, %d", @"two", 3);
	
	Just like NSLog, you can pass in multiple variables too:
	 - 1.571 * 0.785 = 1.233701
	 - One, two, 3
	 
`UALogger` will work alongside of `NSLog`, however, if you setup a Preprocessor Macro called `UALOGGER_SWIZZLE_NSLOG`, you can use UALogger without changing any of your code.

	NSLog(@" - This NSLog call is actually routing through UALogger.");

	
UALog is setup by default to call UALogPlain, but you can change that by adding this to your code:
	
	#undef UALog;
	#define UALog( s, ... ) UALogFull( s, ##__VA_ARGS__ );
	

#### UALogger Class Methods

Even though it makes life easier, you don't _have_ to use any of the `UALogger` macros to use `UALogger`. You can log anything with a simple call:

	[UALogger log:@"I am logging now: %@", [NSDate date]];
	

You can change the format of the `UALogPlain`, `UALogBasic` and `UALogFull` calls:

    [UALogger setFormat:@"UALogger logged: %@" forVerbosity:UALoggerVerbosityPlain];


Then all subsequent log calls for that verbosity will use that format. Take a look at the `setupDefaultFormats` for more info on the defaults. If you want to reset the format, call

	[UALogger resetDefaultLogFormats];
	
#### Production Logging


By default UALogger will log in Debug environments and not in Production. It determines this by the presence of the Preprocessor Macro `DEBUG`, which is added to wevery Xcode project by default. The rules it uses to determine if it should log to the console are:


- It __is not__ a production build and `shouldLogInDebug` is true __OR__
- It __is__ a production build and `shouldLogInProduction` is true __OR__
- The NSUserDefaults key for logging is true.


You can query these values and set them at runtime:

    + (BOOL)isProduction;
    + (BOOL)shouldLogInProduction;
    + (BOOL)shouldLogInDebug;
    + (void)setShouldLogInProduction:(BOOL)shouldLogInProduction;
    + (void)setShouldLogInDebug:(BOOL)shouldLogInDebug;
    + (NSString *)userDefaultsKey;
    + (void)setUserDefaultsKey:(NSString *)userDefaultsKey;

And you can tell if logging is enabled by calling:

    + (BOOL)loggingEnabled;
	

#### Log Collecting

One of the more useful features of `UALogger` is to grab the recent log entries from the console.To do this, simply call:

    [UALogger applicationLog];
	
It can be useful to automatically append to support emails that originate from within your app.
	
    NSString *log = [UALogger applicationLog];
    NSData *data = [log dataUsingEncoding:NSUTF8StringEncoding];
    [mailComposeViewController addAttachmentData:data mimeType:@"text/plain" fileName:@"ApplicationLog.txt"];
    
The `applicationLog` method is synchronous and can take while, so there is also an asynchronous block based method with an onComplete callback:

    [UALogger getApplicationLog:^(NSArray *logs){
        for (NSString *log in logs) {
            // Do something awesome");
        }
    }];


---
### Bugs / Pull Requests
Let me know if you see ways to improve `UALogger` or see something wrong with it. I am happy to pull in pull requests that have clean code, and that is useful for most people. If you want to thanks me for publishing it, you can [buy one of my apps](http://itunes.com/apps/urbanapps?at=11l7j9&ct=github) :)