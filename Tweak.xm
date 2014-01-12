/*@interface SBCCQuickLaunchSectionController {}
        SBControlCenterButton *_torchButton;
        SBControlCenterButton *_clockButton;
        SBControlCenterButton *_calculatorButton;
        SBControlCenterButton *_cameraButton;
        NSMutableArray *_buttons;
        AVFlashlight *_flashlight;
        BOOL _ccVisible;
        NSObject<OS_dispatch_queue> *_flashlightQueue;
        BOOL _flashlightOn;
}
@property(assign, nonatomic, getter=isFlashlightOn) BOOL flashlightOn;
+ (Class)viewClass;
- (id)init;
- (void)_deviceBlockStateDidChangeNotification:(id)_deviceBlockState;
- (void)_enableTorch:(BOOL)torch;*/

@interface AVFlashlightInternal : NSObject{
    BOOL overheated;
    BOOL available;
    float flashlightLevel;
}
@end

@interface AVFlashlight : NSObject{
    AVFlashlightInternal *_internal;
}

@property(readonly, nonatomic) float flashlightLevel;
@property(readonly, nonatomic, getter=isOverheated) BOOL overheated;
@property(readonly, nonatomic, getter=isAvailable) BOOL available;

+(BOOL)hasFlashlight;
+(void)initialize;
-(void)handleNotification:(id)arg1 payload:(id)arg2;

-(id)init;
-(void)dealloc;

-(BOOL)setFlashlightLevel:(float)arg1 withError:(id *)arg2;
-(void)turnPowerOff;
-(BOOL)turnPowerOnWithError:(id *)arg1;

-(void)_refreshIsAvailable;
-(void)teardownFigRecorder;
-(BOOL)ensureFigRecorderWithError:(id *)arg1;
-(BOOL)bringupFigRecorderWithError:(id *)arg1;
@end

@interface SBBacklightController
+(instancetype)sharedInstance;
- (void)_lockScreenDimTimerFired;
- (void)resetLockScreenIdleTimer;
@end

%hook SBBacklightController

-(void)_autoLockTimerFired:(id)fired{
	AVFlashlight *torch = [[AVFlashlight alloc] init];
	NSLog(@"----- altorch: %f", torch.flashlightLevel);
	if(torch.flashlightLevel > 0.f)
		[self resetLockScreenIdleTimer];
	else
		%orig;
}
-(void)_lockScreenDimTimerFired{
	AVFlashlight *torch = [[AVFlashlight alloc] init];
	NSLog(@"----- lstorch: %f", torch.flashlightLevel);
	if(torch.flashlightLevel > 0.f)
		[self resetLockScreenIdleTimer];
	else
		%orig;

    /* legal way (maybe works)
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if(device.torchMode == AVCaptureTorchModeOn)
		[self resetLockScreenIdleTimer];
	else
		%orig;*/
}

%end