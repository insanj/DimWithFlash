#import "substrate.h"

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

@interface SBCCQuickLaunchSectionController
@property(assign, nonatomic, getter=isFlashlightOn) BOOL flashlightOn;
-(void)_updateFlashlightPowerState;
@end

%hook SBCCQuickLaunchSectionController
-(void)_updateFlashlightPowerState{
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"DFUpdateFlashlight" object:nil userInfo:@{@"flashlightOn" : @(self.flashlightOn)}];
	%orig;
}
%end

@interface SBBacklightController
-(id)init;
-(void)dealloc;
-(void)_lockScreenDimTimerFired;
-(void)resetLockScreenIdleTimer;
@end

%hook SBBacklightController
BOOL flashlightOn;

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
	flashlightOn = [notification.userInfo[@"flashlightOn"] boolValue];

}

-(void)_lockScreenDimTimerFired{
	if(flashlightOn){
		[self resetLockScreenIdleTimer];
		return;
	}

	%orig;
}

%end