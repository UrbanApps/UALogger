//
//  UAViewController.m
//  UALoggerExample
//
//  Created by Matt Coneybeare on 9/1/13.
//  Copyright (c) 2013 Urban Apps. All rights reserved.
//

#import "UAViewController.h"
#import <MessageUI/MessageUI.h>

@interface UAViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UITextView *textView;

@end

@implementation UAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UALog(@"\n");
	UALogPlain(@"UALogPlain logs to the console just like NSLog.");
	UALogBasic(@"UALogBasic logs as well, but also logs the file name and line number.");
	UALogFull(@"UALogFull logs the calling object (self), the file name, the line number and the method name.");
	UALog(@"UALog is a short synonym for UALogPlain.");
	

	UALog(@"\n");
	UALog(@"Because UALog works just like NSLog, you can %@ in %@:", @"pass", @"variables");
	UALog(@" - %@", self);
	UALog(@" - %d", arc4random() % 99);
	UALog(@" - %.6f", M_PI);
	UALog(@" - %@.", [NSDate date]);
	
	UALog(@"\n");
	UALog(@"Just like NSLog, you can pass in multiple variables too:");
	UALog(@" - %.3f * %.3f = %.6f", M_PI_2, M_PI_4, M_PI_2 * M_PI_4);
	UALog(@" - One, %@, %d", @"two", 3);
	
	UALog(@"\n");
	NSLog(@"UALogger will work alongside of NSLog.");
	UALog(@"However, if you setup a Preprocessor Macro called UALOGGER_SWIZZLE_NSLOG, you can use UALogger without changing any of your code.");
#ifdef UALOGGER_SWIZZLE_NSLOG
	NSLog(@" - This NSLog call is actually routing through UALogger.");
#else
	NSLog(@" - This NSLog call is NOT routing through UALogger.");
#endif
	
	UALog(@"\n");
	UALog(@"UALog is setup by default to call UALogBasic, but you can change that by adding this to your code:");
	UALog(@"  #undef UALog");
	UALog(@"  #define UALog( s, ... ) UALogFull( s, ##__VA_ARGS__ )");
	
	UALog(@"\n");
	UALog(@"You don't have to use any of the UALogger macros to use UALogger.");
	UALog(@"You can log anything with a simple call:'");
	UALog(@"  [UALogger log:@\"I am logging now: %%@\", [NSDate date]];");
	[UALogger log:@"  I am logging now: %@", [NSDate date]];
	
	UALog(@"\n");
	UALog(@"You can change the format of the UALogPlain, UALogBasic and UALogFull calls:");
	UALog(@" [UALogger setFormat:@\"UALogger logged: %%@\" forVerbosity:UALoggerVerbosityPlain];");
	[UALogger setFormat:@"UALogger logged: %@" forVerbosity:UALoggerVerbosityPlain];
	UALog(@"Then all subsequent log calls for that verbosity will use that format");
	UALog(@"Until you call [UALogger resetDefaultLogFormats];");
	[UALogger resetDefaultLogFormats];
	
	UALog(@"\n");
	UALog(@"By default UALogger will log in Debug environments and not in Production.");
	UALog(@"It determines this by the presence of the Preprocessor Macro DEBUG.");
	UALog(@"The rules it uses to determine if it should log to the console are:");
	UALog(@"  Not a production build and shouldLogInDebug is true OR");
	UALog(@"  Is a production build and shouldLogInProduction is true OR");
	UALog(@"  The NSUserDefaults key for logging is true.");
	UALog(@"\n");
	UALog(@"Currently, the values for those variables are:");
	UALog(@"  [UALogger isProduction]: %@", NSStringFromBool([UALogger isProduction]));
	UALog(@"  [UALogger shouldLogInDebug]: %@", NSStringFromBool([UALogger shouldLogInDebug]));
	UALog(@"  [UALogger shouldLogInProduction]: %@", NSStringFromBool([UALogger shouldLogInProduction]));
	UALog(@"  [UALogger userDefaultsKey]: %@", [UALogger userDefaultsKey]);
	UALog(@"  [[NSUserDefaults standardUserDefaults] boolForKey:%@]: %@", [UALogger userDefaultsKey], NSStringFromBool([UALogger userDefaultsOverride]));
	UALog(@"\n");
	UALog(@"These values as shown mean that logging to the console %@ currently enabled.", ([UALogger loggingEnabled] ? @"is" : @"is not"));
	
	UALog(@"\n");
	UALog(@"One of the more useful features of UALogger is to grab the recent log entries from the console.");
	UALog(@"To do this, simply call:");
	UALog(@"  [UALogger applicationLog];");
	UALog(@"It can be useful to automatically append to support emails that originate from within your app.");
	UALog(@"  NSString *log = [UALogger applicationLog];");
	UALog(@"  NSData *data = [log dataUsingEncoding:NSUTF8StringEncoding];");
	UALog(@"  [mailComposeViewController addAttachmentData:data mimeType:@\"text/plain\" fileName:@\"ApplicationLog.txt\"];");
	UALog(@"But this method can take while, so there is also a block based method with an onComplete callback:");
	UALog(@"  [UALogger getApplicationLog:^(NSArray *logs){");
	UALog(@"      for (NSString *log in logs) {");
	UALog(@"          // Do something awesome");
	UALog(@"      }");
	UALog(@"  }");
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

	self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(self.view.bounds) - 20, CGRectGetHeight(self.view.bounds) - 104)];
	[self.textView setEditable:NO];
	[self.textView setTextColor:[UIColor whiteColor]];
	[self.textView setBackgroundColor:[UIColor blackColor]];
	[self.textView setFont:[UIFont systemFontOfSize:6]];
	[self.textView setText:[NSString stringWithFormat:@"Hang on... Fetching all the log entries for %@", [UALogger bundleName]]];
	[self.view addSubview:self.textView];
	
	
	// Set this so the switch will be the only determining factor on whether to log or not.
	[UALogger setShouldLogInDebug:NO];
	
	UISwitch *switchy = [[UISwitch alloc] initWithFrame:CGRectZero];
	[switchy sizeToFit];
	[switchy setFrame:CGRectMake(CGRectGetMaxX(self.textView.frame) - CGRectGetWidth(switchy.bounds),
								 CGRectGetMaxY(self.textView.frame) + 10,
								 CGRectGetWidth(switchy.bounds),
								 CGRectGetHeight(switchy.bounds))];
	BOOL shouldLog = [UALogger userDefaultsOverride];
	[switchy setOn:shouldLog];
	[switchy addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:switchy];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10,
															   CGRectGetMaxY(self.textView.frame) + 10,
															   CGRectGetMinY(switchy.frame) - 10,
															   CGRectGetHeight(switchy.bounds))];
	[label setText:@"Log to Console"];
	[self.view addSubview:label];
	
	[self.view bringSubviewToFront:switchy];
	
	// Button as an example of a log collection.
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[button setFrame:CGRectMake(10,
								CGRectGetMaxY(label.frame) + 10,
								CGRectGetWidth(self.textView.bounds),
								44)];
	[button setTitle:@"Email Log" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(emailLog:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:button];
	[button setEnabled:NO];
	
	
	
	[UALogger getApplicationLog:^(NSArray *logs){
		dispatch_async(dispatch_get_main_queue(), ^{
			NSString *logText = [logs componentsJoinedByString:@"\n"];
			[self.textView setText:logText];
			[button setEnabled:YES];
		});
	}];
	
}



- (BOOL)prefersStatusBarHidden {
	return YES;
}


- (void)switchToggled:(UISwitch *)sender {
	[[NSUserDefaults standardUserDefaults] setBool:[sender isOn]
											forKey:[UALogger userDefaultsKey]];
	[[NSUserDefaults standardUserDefaults] synchronize];
	UALog(@"Switch Toggled. Logging Enabled? %@", NSStringFromBool([UALogger loggingEnabled]));
}

- (void)emailLog:(id)sender {
	if ([MFMailComposeViewController canSendMail]) {
		[sender setEnabled:NO];
		self.textView.text = @"Re-generating log file...";
		
		MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
		mail.mailComposeDelegate = self;
		[UALogger getApplicationLog:^(NSArray *logs){
			dispatch_async(dispatch_get_main_queue(), ^{
				NSString *logText = [logs componentsJoinedByString:@"\n"];
				[self.textView setText:logText];
				[sender setEnabled:YES];
				
				
				NSData *data = [logText dataUsingEncoding:NSUTF8StringEncoding];
				[mail addAttachmentData:data mimeType:@"text/plain" fileName:@"Application Log.txt"];
				[self presentViewController:mail animated:YES completion:nil];
			});
		}];
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
