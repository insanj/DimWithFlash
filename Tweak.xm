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
	NSNumber *flashlightOn = [NSNumber numberWithBool:MSHookIvar<BOOL>(self, "_flashlightOn")];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"DFUpdateFlashlight" object:nil userInfo:@{@"flashlightOn" : flashlightOn}];
	%orig;
}
%end

@interface SBBacklightController
+(instancetype)sharedInstance;
-(id)init;
-(void)_lockScreenDimTimerFired;
-(void)resetLockScreenIdleTimer;
-(void)setIdleTimerDisabled:(BOOL)disabled;
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
	if([notification.userInfo[@"flashlightOn"] boolValue])
		[[%c(SBBacklightController) sharedInstance] setIdleTimerDisabled:YES];
	else
		[[%c(SBBacklightController) sharedInstance] setIdleTimerDisabled:NO];
}

%end