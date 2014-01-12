#import "substrate.h"

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

@interface SBCCQuickLaunchSectionController{
        BOOL _flashlightOn;
}
@property(assign, nonatomic, getter=isFlashlightOn) BOOL flashlightOn;
- (void)_enableTorch:(BOOL)torch;
- (void)_updateFlashlightPowerState;
@end

%hook SBCCQuickLaunchSectionController
-(void)_updateFlashlightPowerState{
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"DFUpdateFlashlight" object:nil userInfo:@{@"flashlightOn" : @(self.flashlightOn)}];
	%orig;
}
%end

@interface SBBacklightController
+(instancetype)sharedInstance;
-(id)init;
-(void)_lockScreenDimTimerFired;
-(void)resetLockScreenIdleTimer;
-(void)preventIdleSleep;
-(void)allowIdleSleep;
-(void)setIdleTimerDisabled:(BOOL)disabled;

-(void)cancelLockScreenIdleTimer;
-(double)defaultLockScreenDimInterval;
-(void)resetLockScreenIdleTimer;

@end

%hook SBBacklightController
-(id)init{
	SBBacklightController *original = %orig;
	[[NSDistributedNotificationCenter defaultCenter] addObserver:original selector:@selector(updateFlashlight:) name:@"DFUpdateFlashlight" object:nil];
	return original;
}

-(void)dealloc{
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	%orig;
}

%new -(void)updateFlashlight:(NSNotification *)notification{
	SBBacklightController *controller = [%c(SBBacklightController) sharedInstance];
	NSTimer *idleTimer = MSHookIvar<NSTimer *>(controller, "_autoLockTimer");
	if([notification.userInfo[@"flashlightOn"] boolValue]){
		NSLog(@"---- if! %@", idleTimer);	//null
		[controller cancelLockScreenIdleTimer];
		//[controller setIdleTimerDisabled:YES];
		//[controller preventIdleSleep];
	}

	else{
		NSLog(@"---- else! %@", idleTimer);

		//[controller setIdleTimerDisabled:NO];
		//[controller allowIdleSleep];
	}

	NSLog(@"---- leaving! %@", idleTimer);
}

%end