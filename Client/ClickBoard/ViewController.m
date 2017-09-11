//
//  ViewController.m
//  Test
//
//  Created by Hugh Bellamy on 12/10/2014.
//  Copyright (c) 2014 Hugh Bellamy. All rights reserved.
//
#import "ViewController.h"

#import "UIResponder+KeyboardCache.h"
#import "UIImage+Additions.h"

#import "ClickBoardConstants.h"
#import "ScrollSlider.h"
#import "ProgramWindow.h"
#import "BackgroundView.h"

@import CoreMotion;
@import MediaPlayer;
@import AudioToolbox;

#define kUpdateInterval (1.0f / 100.0f)

@interface ViewController ()

//Format: name, filePath; name, filePath
@property (strong, nonatomic) NSArray *apps;
@property (strong, nonatomic) MPVolumeView *volumeView;

@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (weak, nonatomic) IBOutlet UIButton *leftPowerpointButton;
@property (weak, nonatomic) IBOutlet UIButton *rightPowerpointButton;

@property (weak, nonatomic) IBOutlet UIButton *playPauseMediaButton;
@property (weak, nonatomic) IBOutlet UISlider *mediaVolumeSlider;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *widgetArray;

@property (weak, nonatomic) IBOutlet KeyboardTextField *keyboardView;

@property (strong, nonatomic) MODropAlertView *alertView;

@property (strong, nonatomic) CMMotionManager *motionManager;

@property (assign, nonatomic) YRotatingState rotatingX;
@property (assign, nonatomic) YMovementState movementY;

@property (strong, nonatomic) CMAttitude *latestAttitudeX;

@property (assign, nonatomic) double threshold;
@property (assign, nonatomic) CGFloat speedY;

@property (strong, nonatomic) NSTimer *timer;

@property (assign, nonatomic) BOOL shouldOpenKeyboard;

@property (assign, nonatomic) BOOL cancelTouches;

@property (assign, nonatomic) BOOL shouldNotOpenAlert;

@property (weak, nonatomic) IBOutlet UISlider *opacitySlider;

@property (weak, nonatomic) IBOutlet UIButton *foregroundColourButton;

@property (weak, nonatomic) IBOutlet UILabel *mediaTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *mediaArtistLabel;
@property (weak, nonatomic) IBOutlet UILabel *mediaAlbumLabel;
@property (assign, nonatomic) BOOL shouldNotSendRequest;

@property (weak, nonatomic) IBOutlet UIView *apps2x1;
@property (weak, nonatomic) IBOutlet UIView *apps3x2;
@property (weak, nonatomic) IBOutlet UIView *apps4x2;
@property (weak, nonatomic) IBOutlet UIView *apps3x4;

@property (strong, nonatomic) UIView *appsView;

@property (weak, nonatomic) IBOutlet UIScrollView *upperScrollView;
@property (weak, nonatomic) IBOutlet UIView *mouseViews;
@property (weak, nonatomic) IBOutlet UIView *appsViews;

@property (weak, nonatomic) IBOutlet UIButton *appsButton;
@property (weak, nonatomic) IBOutlet UIButton *appsGearButton;

@property (assign, nonatomic) CGFloat accelerationThreshold;
@property (assign, nonatomic) CGFloat speedThreshold;
@property (assign, nonatomic) NSInteger sampleNumber;
@property (assign, nonatomic) BOOL movingUp;

@property (strong, nonatomic) CMDeviceMotion *previousDeviceMotion;

@property (strong, nonatomic) NSArray *windows;

@property (weak, nonatomic)  IBOutlet UITableView *windowsTableView;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupApps];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UINavigationItem *ipcNavBarTopItem;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Reset"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(resetBackground:)];
    
    UINavigationBar *bar = navigationController.navigationBar;
    [bar setHidden:NO];
    ipcNavBarTopItem = bar.topItem;
    ipcNavBarTopItem.title = @"Photos";
    ipcNavBarTopItem.leftBarButtonItem = doneButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shouldNotOpenAlert = NO;
    self.motionManager = [[CMMotionManager alloc]init];
    self.movementY = YMovementStateNone;
    self.motionManager.accelerometerUpdateInterval = kUpdateInterval;
    self.speedThreshold = 0.01;
    self.accelerationThreshold = 0.005;
    
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        if(!self.cancelTouches) {
            //NSLog(@"%f, %f", motion.userAcceleration.x, motion.userAcceleration.y);
            CMAttitude *attitude = motion.attitude;
            float deltaYaw = attitude.yaw - self.latestAttitudeX.yaw;
            
            CBSpeed speed = CBSpeedNone;
            
            if(deltaYaw > self.threshold) {
                self.rotatingX = XRotatingStateLeft;
            }
            else if(deltaYaw < -self.threshold) {
                self.rotatingX = XRotatingStateRight;
            }
            else {
                self.rotatingX = XRotatingStateNone;
            }
            self.latestAttitudeX = attitude;
            
            float deltaYawAbs = fabsf(deltaYaw);
            if(deltaYawAbs > self.threshold) {
                if(deltaYawAbs < self.threshold * 2) {
                    speed = CBSpeedVerySlow;
                }
                else if(deltaYawAbs < self.threshold * 3) {
                    speed = CBSpeedSlow;
                }
                else if(deltaYawAbs < self.threshold * 4) {
                    speed = CBSpeedMedium;
                }
                else if(deltaYawAbs < self.threshold * 5) {
                    speed = CBSpeedFast;
                }
                else if(deltaYawAbs < self.threshold * 6){
                    speed = CBSpeedVeryFast;
                }
                else {
                    speed = CBSpeedExtremelyFast;
                }
            }
            
            /*CMAcceleration acceleration = motion.userAcceleration;
             float deltaY = 0.0;
             
             if(acceleration.y > self.accelerationThreshold) {
             //Down
             
             deltaY = acceleration.y * self.motionManger.accelerometerUpdateInterval;
             self.movementY = YMovementStateDown;
             //if(self.movementY == YMovementStateDown || self.movementY == YMovementStateNone) {
             //We're moving down and still are
             //self.movementY = YMovementStateDown;
             //deltaY = acceleration.y * self.motionManger.accelerometerUpdateInterval;
             //}
             //else if(self.movementY == YMovementStateUp) {
             //We're moving up but are now slowing down
             //deltaY = -(fabs(acceleration.y)) * self.motionManger.accelerometerUpdateInterval;
             //}
             }
             else if(acceleration.y < -self.accelerationThreshold) {
             //Up
             if(self.movementY == YMovementStateDown) {
             deltaY = fabsf(acceleration.y) * self.motionManger.accelerometerUpdateInterval;
             }
             else {
             deltaY = acceleration.y * self.motionManger.accelerometerUpdateInterval;
             self.movementY = YMovementStateUp;
             }
             //if(self.movementY == YMovementStateUp || self.movementY == YMovementStateNone) {
             //We're moving up and still up
             //self.movementY = YMovementStateUp;
             //}
             //else if(self.movementY == YMovementStateDown) {
             //We're moving down but are now slowing down
             //deltaY = (fabs(acceleration.y)) * self.motionManger.accelerometerUpdateInterval;
             //}
             }
             
             self.speedY += deltaY;
             //if(self.speedY != 0) {
             //NSLog(@"%f", self.speedY);
             //}
             
             if(deltaY != 0 && !self.timer) {
             if(self.speedY > self.threshold * 3/4) {// && acceleration.y > self.accelerationThreshold) {
             //Moving down
             //NSLog(@"Down");
             self.movementY = YMovementStateDown;
             }
             else if(self.speedY < -(self.threshold * 3/ 4)){//if(self.speedY < -self.threshold * 3/4 && acceleration.y < -self.accelerationThreshold) {
             //Moving up
             //NSLog(@"Up");
             self.movementY = YMovementStateUp;
             }
             
             }
             else {
             self.speedY = 0;
             if(!self.timer) {
             self.timer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(time:) userInfo:nil repeats:NO];
             }
             }*/
            
            
            CMAcceleration currentAcceleration = motion.userAcceleration;
            
            if(fabs(currentAcceleration.y) > self.accelerationThreshold) {
                NSInteger sampleMax = 8;
                if(self.previousDeviceMotion && self.sampleNumber > sampleMax) {
                    //If our current motion mismatches previous motion
                    if(self.previousDeviceMotion.userAcceleration.y > 0 && motion.userAcceleration.y < 0) {
                        self.sampleNumber = 0;
                    }
                    else if(self.previousDeviceMotion.userAcceleration.y < 0 && motion.userAcceleration.y > 0) {
                        self.sampleNumber = 0;
                    }
                }
                if(self.speedY == 0 || self.sampleNumber <= sampleMax) {
                    if(currentAcceleration.x > 0) {
                        self.movingUp = NO;
                    }
                    else {
                        self.movingUp = YES;
                    }
                }
                self.sampleNumber++;
                CGFloat modifier = self.motionManager.accelerometerUpdateInterval * currentAcceleration.y;
                if(self.movingUp) {
                    self.speedY += modifier;
                }
                else {
                    self.speedY -= modifier;
                }
                
                if(fabs(self.speedY) > self.speedThreshold) {
                    if(self.speedY > 0) {
                        //NSLog(@"Up");
                        self.movementY = YMovementStateUp;
                    }
                    else {
                        //NSLog(@"Down");
                        self.movementY = YMovementStateDown;
                    }
                }
            }
            else {
                self.speedY = 0;
                self.sampleNumber = 0;
                self.previousDeviceMotion = nil;
            }
            
            CBSpeed YSpeed = CBSpeedNone;
            float deltaYAbs = fabs(currentAcceleration.y);//fabsf(deltaY);
            if(deltaYAbs > self.accelerationThreshold && fabs(self.speedY) > self.speedThreshold) {
                if(deltaYAbs <= self.accelerationThreshold * 1) {
                    YSpeed = CBSpeedVerySlow;
                    //NSLog(@"Very Slow");
                }
                else if(deltaYAbs < self.accelerationThreshold * 100.0) {
                    YSpeed = CBSpeedSlow;
                    //NSLog(@"Slow");
                }
                else if(deltaYAbs < self.accelerationThreshold * 150.0) {
                    YSpeed = CBSpeedMedium;
                    //NSLog(@"Medium");
                }
                else if(deltaYAbs < self.accelerationThreshold * 200.0) {
                    YSpeed = CBSpeedFast;
                    //NSLog(@"Fast");
                }
                else if(deltaYAbs < self.accelerationThreshold * 275.0){
                    YSpeed = CBSpeedVeryFast;
                    //NSLog(@"Very Fast");
                }
                else {
                    YSpeed = CBSpeedExtremelyFast;
                    //NSLog(@"Extremely Fast");
                }
            }
            if(!(self.rotatingX == XRotatingStateNone && fabs(self.speedY) < self.speedThreshold)) {
                [self.server sendString:[NSString stringWithFormat:@"z:a%@,%@,%@,%@", @(self.rotatingX), @(speed), @(self.movementY), @(YSpeed)]];
            }
            self.previousDeviceMotion = motion;
        }
    }];
    
    CGRect frame = self.view.frame;
    if(frame.size.height < 500) {
        //iPhone 4
        CGRect left = self.leftButton.frame;
        left.size.height = 263;
        self.leftButton.frame = left;
        
        CGRect right = self.rightButton.frame;
        right.size.height = 263;
        self.rightButton.frame = right;
        
        CGRect widgetsFrame = self.widgets.frame;
        widgetsFrame.origin.y = 290;
        widgetsFrame.size.height = frame.size.height - 270;
        self.widgets.frame = widgetsFrame;
        
        for(UIView *view in self.widgets.subviews) {
            CGRect frame = view.frame;
            frame.size.height = self.widgets.frame.size.height - 20;
            view.frame = frame;
        }
        
        CGRect pageControlFrame = self.pageControl.frame;
        pageControlFrame.origin.x = self.widgets.frame.size.height - pageControlFrame.size.height;
        self.pageControl.frame = pageControlFrame;
        
        CGRect frame2 = self.appsViews.frame;
        frame2.origin.x = self.view.frame.size.width;
        frame2.size.width = self.view.frame.size.width;
        self.appsViews.frame = frame2;
    }
    
    [self setupSettings];
    
    [self setupKeyboard];
    
    [self setupScrolling];
    
    [self setupTrackpad];
    
    [self setupLockButton];
}

- (void)setupApps {
    self.apps = [ClickBoardConstants apps];
    BOOL reset = NO;
    if(!self.apps || reset) {
        self.apps = @[@[@"Google Chrome", @"chrome"], @[@"Microsoft Word", @"winword"], @[@"Power Point", @"powerpnt"], @[@"Explorer", @"explorer"], @[@"Start", @"start"], @[@"Show Desktop", @"desktop"], @[@"Excel", @"excel"], @[@"iTunes", @"itunes"], @[@"Safari", @"safari"], @[@"Skype", @"skype"], @[@"Internet Explorer", @"iexplore"], @[@"Mozilla Firefox", @"firefox"]];
        [ClickBoardConstants setApps:self.apps];
        [ClickBoardConstants setAppsView:AppsView3x4];
        [ClickBoardConstants setForegroundColour:[UIColor whiteColor]];
    }
    
    self.apps2x1.hidden = YES;
    self.apps3x2.hidden = YES;
    self.apps3x4.hidden = YES;
    self.apps4x2.hidden = YES;
    
    AppsView appsView = [ClickBoardConstants appsView];
    if(appsView == AppsView2x1) {
        self.apps2x1.hidden = NO;
        self.appsView = self.apps2x1;
    }
    else if(appsView == AppsView3x2) {
        self.apps3x2.hidden = NO;
        self.appsView = self.apps3x2;
    }
    else if(appsView == AppsView3x4) {
        self.apps3x4.hidden = NO;
        self.appsView = self.apps3x4;
    }
    else if(appsView == AppsView4x2) {
        self.apps4x2.hidden = NO;
        self.appsView = self.apps4x2;
    }
    
    //PCType type = [ClickBoardConstants PCType];
    
    for(NSUInteger i = 0; i < self.apps.count; i++) {
        NSArray *app = self.apps[i];
        NSString *name = [app firstObject];
        UIButton *appButton = (UIButton*)[self.appsView viewWithTag:100 + i];
        appButton.backgroundColor = [UIColor clearColor];
        [appButton setTitle:name forState:UIControlStateNormal];
        appButton.titleLabel.numberOfLines = 0;
        appButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [appButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        //[appButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        appButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        appButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        appButton.titleLabel.minimumScaleFactor = 0.5;
        /*NSString *name = [app lastObject];
         
         NSString *imageName = name;
         if(type == PCTypeWindows) {
         imageName = [imageName stringByAppendingString:@"_windows.png"];
         }
         else if(type == PCTypeMac) {
         imageName = [imageName stringByAppendingString:@"_mac.png"];
         }
         UIImage *image = [UIImage imageNamed:imageName];
         
         UIButton *appButton = (UIButton*)[self.appsView viewWithTag:100 + i];
         appButton.backgroundColor = [UIColor clearColor];
         [appButton setBackgroundImage:image forState:UIControlStateNormal];*/
    }
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
   
    [self.windowsTableView addGestureRecognizer:lpgr];
    self.windowsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.windowsTableView.separatorColor = [UIColor clearColor];
}

- (void)setupKeyboard {
    [UIResponder cacheKeyboard];
    self.keyboardView.extendedDelegate = self;
    self.keyboardView.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.keyboardView setupToolbar];
    
    float index = 0;
    
    for(UIView *widget in self.widgets.subviews) {
        if(widget.tag >= 200) {
            index++;
            NSInteger order = widget.tag - 200;
            CGRect frame = self.widgets.bounds;
            frame.origin.x = order * frame.size.width;
            widget.frame = frame;
        }
    }
    
    self.pageControl.numberOfPages = index;
    self.widgets.contentSize = CGSizeMake(index * self.widgets.frame.size.width, self.widgets.frame.size.height);
    
    self.pageControl.currentPage = 5;
    [self pageViewChanged:self.pageControl];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.widgets.frame.size.width;
    int page = floor((self.widgets.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    if(page == 6 && !self.keyboardView.isFirstResponder	 && self.shouldOpenKeyboard) {
        [self.keyboardView becomeFirstResponder];
    }
    else if(page != 6) {
        self.shouldOpenKeyboard = YES;
    }
    
    if(page == 4) {
        self.cancelTouches = YES;
    }
    else {
        self.cancelTouches = NO;
    }
    
    if(page != 5) {
        [self.upperScrollView scrollRectToVisible:CGRectMake(0, 0, self.upperScrollView.frame.size.width, self.upperScrollView.frame.size.height) animated:YES];
        [self.appsGearButton setBackgroundImage:[UIImage imageNamed:@"settings1.png"] forState:UIControlStateNormal];
    }
    
    if(page == 5 || page == 3 || page == 3 || page == 2) {
        if(!self.shouldNotSendRequest) {
            //TODO CHANGE TO I
            [self.server sendString:@"v:v"];
            [self.server sendString:@"i:i"];
            self.shouldNotSendRequest = YES;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.shouldNotSendRequest = NO;
}

- (IBAction)pageViewChanged:(UIPageControl *)sender {
    CGRect frame = CGRectZero;
    frame.origin.x = self.widgets.frame.size.width * self.pageControl.currentPage;
    frame.size = self.widgets.frame.size;
    [self.widgets scrollRectToVisible:frame animated:YES];
}

- (void)setupScrolling {
    self.upperScrollView.contentSize = CGSizeMake(self.upperScrollView.frame.size.width * 2, self.upperScrollView.frame.size.height);
    self.threshold = 0.002;
    //self.accelerationThreshold = 0.025;
    UISwipeGestureRecognizer *swipeGestureRecogniserUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiped:)];
    swipeGestureRecogniserUp.direction = UISwipeGestureRecognizerDirectionUp;
    swipeGestureRecogniserUp.delegate = self;
    [self.view addGestureRecognizer:swipeGestureRecogniserUp];
    
    UISwipeGestureRecognizer *swipeGestureRecogniserDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiped:)];
    swipeGestureRecogniserDown.direction = UISwipeGestureRecognizerDirectionDown;
    swipeGestureRecogniserUp.delegate = self;
    [self.view addGestureRecognizer:swipeGestureRecogniserDown];
}

- (void)setupSettings {
    [self setupApps];
    
    [self setupBackground];
    [self setupForeground];
    [self setupOpacity];
}

- (void)setupBackground {
    NSString *backgroundImageName = [ClickBoardConstants backgroundImageName];
    if(!backgroundImageName) {
        backgroundImageName = @"background.png";
        [ClickBoardConstants setBackgroundImageName:backgroundImageName];
    }
    UIImage *backgroundImage;
    if([backgroundImageName isEqualToString:@"background.png"] || [backgroundImageName isEqualToString:@"background3.png"] || [backgroundImageName isEqualToString:@"background4.png"]) {
        backgroundImage = [UIImage imageNamed:backgroundImageName];
    }
    else {
        backgroundImage = [UIImage imageWithContentsOfFile:[[ClickBoardConstants appDirectory] stringByAppendingPathComponent:backgroundImageName]];
    }
    
    if(!backgroundImage) {
        [ClickBoardConstants setBackgroundImageName:@"background.png"];
        backgroundImage = [UIImage imageNamed:@"background.png"];
    }
    
    self.backgroundView.image = backgroundImage;
}

- (void)setupForeground {
    UIColor *colour = [ClickBoardConstants foregroundColour];
    if(!colour) {
        colour = [UIColor whiteColor];
    }
    
    self.foregroundColourButton.backgroundColor = colour;
    [self.appsButton setTitleColor:colour forState:UIControlStateNormal];
    for(UIView *view in self.widgetArray) {
        for (UIView *subview in view.subviews) {
            if(subview.tag == -1) {
                continue;
            }
            
            if([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton*)subview;
                if(button.currentImage) {
                    UIImage *tintedImage = [button.currentImage add_tintedImageWithColor:colour style:ADDImageTintStyleKeepingAlpha];
                    [button setImage:tintedImage forState:UIControlStateNormal];
                }
                else if(button.currentBackgroundImage) {
                    UIImage *tintedImage = [button.currentBackgroundImage add_tintedImageWithColor:colour style:ADDImageTintStyleKeepingAlpha];
                    [button setBackgroundImage:tintedImage forState:UIControlStateNormal];
                }
                button.tintColor = colour;
                if(!(button.tag >= 100 && button.tag < 200) && button.tag != -2) {
                    [button setTitleColor:colour forState:UIControlStateNormal];
                }
            }
            else if([subview isKindOfClass:[UISlider class]]) {
                UISlider *slider = (UISlider*)subview;
                [slider setMinimumTrackTintColor:colour];
                [slider setMaximumTrackTintColor:colour];
                [slider setThumbImage:nil forState:UIControlStateNormal];
            }
            else if([subview isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel*)subview;
                [label setTextColor:colour];
            }
            else if ([subview isKindOfClass:[UIView class]]) {
                for (UIView *subsubview in subview.subviews) {
                    if([subsubview isKindOfClass:[UIButton class]]) {
                        UIButton *button = (UIButton*)subsubview;
                        if(button.currentImage) {
                            UIImage *tintedImage = [button.currentImage add_tintedImageWithColor:colour style:ADDImageTintStyleKeepingAlpha];
                            [button setImage:tintedImage forState:UIControlStateNormal];
                        }
                        else if(button.currentBackgroundImage) {
                            UIImage *tintedImage = [button.currentBackgroundImage add_tintedImageWithColor:colour style:ADDImageTintStyleKeepingAlpha];
                            [button setBackgroundImage:tintedImage forState:UIControlStateNormal];
                        }
                        button.tintColor = colour;
                        [button setTitleColor:colour forState:UIControlStateNormal];
                    }
                }
            }
        }
    }
    
    UIImage *leftImage = [self.leftButton.currentImage add_tintedImageWithColor:colour style:ADDImageTintStyleKeepingAlpha];
    UIImage *rightImage = [self.rightButton.currentImage add_tintedImageWithColor:colour style:ADDImageTintStyleKeepingAlpha];
    
    [self.leftButton setImage:leftImage forState:UIControlStateNormal];
    [self.rightButton setImage:rightImage forState:UIControlStateNormal];
    
    self.pageControl.currentPageIndicatorTintColor = colour;
}

- (void)setupOpacity {
    float opacity = [ClickBoardConstants mouseOpacity];
    if(![[NSUserDefaults standardUserDefaults] objectForKey:USER_MOUSE_OPACITY_KEY]) {
        opacity = 0.5;
        [ClickBoardConstants setMouseOpacity:opacity];
    }
    
    self.leftButton.alpha = opacity;
    self.rightButton.alpha = opacity;
    
    self.opacitySlider.value = opacity;
}
CGFloat oldVolume = 1;

- (void)setupTrackpad {;
    UIPanGestureRecognizer *panGestureRecogniser = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panned:)];
    panGestureRecogniser.delegate = self;
    [self.touchpadView addGestureRecognizer:panGestureRecogniser];
}

- (void)panned:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint touch = [panGestureRecognizer locationInView:self.touchpadView];
    CGFloat ratioX = touch.x / self.touchpadView.frame.size.height;
    CGFloat ratioY = touch.y / self.touchpadView.frame.size.width;
    [self.server sendString:[NSString stringWithFormat:@"y:a%f,%f", ratioX, ratioY]];
}

- (void)setupLockButton {
    self.volumeView = [[MPVolumeView alloc]init];
    UISlider* volumeViewSlider = nil;
    for (UIView *view in [self.volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    
    [volumeViewSlider setValue:0.5f animated:YES];
    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lock:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}

- (void)alertViewPressButton:(MODropAlertView *)alertView buttonType:(DropAlertButtonType)buttonType {
    //[alertView dismiss];
    //[self clickBoardServer:self.server didCompleteRemoteConnectionWithService:[[NSNetService alloc] init]];
    if(alertView.tag == -2) {
        //First rotation
        [ClickBoardConstants setRotatedBefore:YES];
        self.alertView = nil;
        self.shouldNotOpenAlert = NO;
        [alertView dismiss];
    }
    else if(alertView.tag == -3) {
        //A help message
        [alertView dismiss];
        self.shouldNotOpenAlert = NO;
        self.alertView = nil;
    }
    else if(alertView.tag >= 100) {
        [alertView dismiss];
        self.alertView = nil;
        self.shouldNotOpenAlert = NO;
        if(alertView.tag - 100 < self.windows.count && buttonType != DropAlertButtonOK) {
            Window *window = self.windows[alertView.tag - 100];
            [self.server sendString:[NSString stringWithFormat:@"x:%@", window.pid]];
        }
    }
}

- (IBAction)changeForeground:(id)sender {
    [self performSegueWithIdentifier:@"colour" sender:nil];
}

- (void)colorPickerViewController:(ChooseColorViewController *)colorPicker didSelectColor:(UIColor *)color{
    [ClickBoardConstants setForegroundColour:color];
    [self setupForeground];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)colorPickerViewControllerDidCancel:(ChooseColorViewController *)colorPicker {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.shouldNotOpenAlert = YES;
    if([segue.destinationViewController isKindOfClass:[ChooseColorViewController class]]) {
        ChooseColorViewController *viewController = segue.destinationViewController;
        viewController.delegate = self;
        viewController.image = self.backgroundView.image;
        viewController.color = [ClickBoardConstants foregroundColour];
    }
}

- (IBAction)changeBackground:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) {
        [[[MODropAlertView alloc]initDropAlertWithTitle:@"Error" description:@"Unable to access photo library. Have you allowed ClickBoard access to your photos?" okButtonTitle:@"OK"]show];
    }
    
    self.shouldNotOpenAlert = YES;
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetBackground:)];
    imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:
                              UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)resetBackground:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset Background" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *original = [UIAlertAction actionWithTitle:@"Original" style:UIAlertActionStyleCancel handler:^(UIAlertAction* action) {
        [ClickBoardConstants setBackgroundImageName:@"background.png"];
        [self setupBackground];
    }];
    UIAlertAction *flowers = [UIAlertAction actionWithTitle:@"Flowers" style:UIAlertActionStyleCancel handler:^(UIAlertAction* action) {
        [ClickBoardConstants setBackgroundImageName:@"background3.png"];
        [self setupBackground];
    }];
    UIAlertAction *nebula = [UIAlertAction actionWithTitle:@"Nebula" style:UIAlertActionStyleCancel handler:^(UIAlertAction* action) {
        [ClickBoardConstants setBackgroundImageName:@"background4.png"];
        [self setupBackground];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:original];
    [alert addAction:flowers];
    [alert addAction:nebula];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    
    UIImage *imageToUse;
    if (editedImage) {
        imageToUse = editedImage;
    } else {
        imageToUse = originalImage;
    }
    
    if(imageToUse) {
        NSString *storePath = [[ClickBoardConstants appDirectory] stringByAppendingPathComponent:@"background2.png"];
        
        NSData *imageData = UIImagePNGRepresentation(imageToUse);
        [imageData writeToFile:storePath atomically:YES];
        [ClickBoardConstants setBackgroundImageName:@"background2.png"];
        [self setupBackground];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeOpacity:(UISlider*)slider {
    [ClickBoardConstants setMouseOpacity:slider.value];
    [self setupOpacity];
}

#pragma mark - Movement

- (void)time:(NSTimer*)timer {
    self.movementY = YMovementStateNone;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)clickBoardServer:(ClickBoardServer *)server didAcceptData:(NSData *)data {
    NSString *message = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if([message hasPrefix:@"1"]) {
        //We're getting our application data
        //message = [message substringFromIndex:1];
        //NSLog(@"%@", message);
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (void)swiped:(UISwipeGestureRecognizer*)swipeGestureRegognizer {
    if(self.portraitView.hidden) {
        return;
    }
    [self.keyboardView resignFirstResponder:YES];
    NSString *direction = @"";
    switch (swipeGestureRegognizer.direction) {
        case UISwipeGestureRecognizerDirectionUp:
            //Swiped up, scroll down
            direction = @"1";
            break;
        case UISwipeGestureRecognizerDirectionDown:
            //Swiped down, scroll up
            direction = @"2";
            break;
        default:
            break;
    }
    
    if(direction.length > 0) {
        [self.server sendString:[@"c:" stringByAppendingString:direction]];
    }
}

- (IBAction)taskManagerAction:(UIButton *)sender {
    [self.server sendString:[NSString stringWithFormat:@"f:%ld",(long)sender.tag]];
}

BOOL done = NO;
- (void)lock:(NSNotification *)notification {
    //[self.server sendString:@"f"];
    [self.keyboardView resignFirstResponder:YES];
    if(self.portraitView.hidden) {
        CGFloat volume = [[notification userInfo][@"AVSystemController_AudioVolumeNotificationParameter"]floatValue];
        if(volume == 1 && oldVolume == 1) {
            //Left click
            [self.server sendString:@"a:3"];
        }
        else if(oldVolume == 0 && volume == 0) {
            //Right click
            [self right:nil];
        }
        else if(volume > oldVolume) {
            //Left click
            [self.server sendString:@"a:3"];
        }
        else {
            //Right click
            [self right:nil];
        }
        oldVolume = volume;
    }
    else if(done) {
        //[self.alertView dismiss];
    }
    done = YES;
}

- (IBAction)leftDown:(id)sender {
    [self.server sendString:@"a:1"];
}

- (IBAction)leftUp:(id)sender {
    [self.server sendString:@"a:2"];
}

- (IBAction)right:(id)sender {
    [self.server sendString:@"b"];
}

- (IBAction)powerPointLeft:(id)sender {
    [self.server sendString:@"e:kl"];
}

- (IBAction)powerPointRight:(id)sender {
    [self.server sendString:@"e:kr"];
}

- (IBAction)powerPointPresent:(id)sender {
    [self.server sendString:@"e:f5"];
}

- (IBAction)powerPointEnd:(id)sender {
    [self.server sendString:@"e:ec"];
}

- (IBAction)launchApp:(UIButton *)sender {
    NSUInteger index = sender.tag - 100;
    if(index < self.apps.count) {
        NSArray *app = self.apps[index];
        if(app.count >= 2) {
            [self.server sendString:[@"d:" stringByAppendingString:[app lastObject]]];
        }
    }
    [self.keyboardView resignFirstResponder:YES];
}

- (void)textFieldDidResign:(KeyboardTextField *)textField {
    CGRect frame;
    frame.origin.x = self.widgets.frame.size.width * 5;
    frame.origin.y = 0;
    frame.size = self.widgets.frame.size;
    [self.widgets scrollRectToVisible:frame animated:YES];
    self.shouldOpenKeyboard = NO;
}

- (void)textFieldDidDelete:(KeyboardTextField *)textField {
    [self.server sendString:@"e:bs"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.server sendString:@"e:rt"];
    return false;
}

- (void)textFieldDidChangeText:(KeyboardTextField *)textField {
    NSString *message = @"";
    if(self.keyboardView.ctrlButton.selected) {
        message = [message stringByAppendingString:@"ct"];
        [self.keyboardView.ctrlButton toggleSelected];
    }
    if(self.keyboardView.fnButton.selected) {
        message = [message stringByAppendingString:@"f"];
        [self.keyboardView.fnButton toggleSelected];
        textField.inputView = nil;
        [textField setKeyboardType:UIKeyboardTypeDefault];
        [textField resignFirstResponder];
        [textField becomeFirstResponder];
    }
    if(self.keyboardView.winButton.selected) {
        message = [message stringByAppendingString:@"wn"];
        [self.keyboardView.winButton toggleSelected];
    }
    if(self.keyboardView.altButton.selected) {
        message = [message stringByAppendingString:@"at"];
        [self.keyboardView.altButton toggleSelected];
    }
    
    [self.server sendString:[[@"e:" stringByAppendingString:message]stringByAppendingString: textField.text]];
    
    textField.text = @"";
}

- (void)textField:(KeyboardTextField *)textField didToggleModifierKey:(KeyboardTextFieldModiferKey)key {
    if(key == KeyboardTextFieldModiferKeyFn) {
        if(self.keyboardView.fnButton.selected) {
            textField.inputView = nil;
            [textField setKeyboardType:UIKeyboardTypeNumberPad];
            [textField resignFirstResponder];
            [textField becomeFirstResponder];
        }
        else {
            textField.inputView = nil;
            [textField setKeyboardType:UIKeyboardTypeDefault];
            [textField resignFirstResponder];
            [textField becomeFirstResponder];
        }
    }
}

- (IBAction)previousTrack:(id)sender {
    [self.server sendString:@"g:pt"];
}

- (IBAction)playPauseTrack:(UIButton*)sender {
    [self setupPlayPauseButton:sender.tag];
    if(self.playPauseMediaButton.tag) {
        [self.server sendString:@"g:pl"];
    }
    else {
        [self.server sendString:@"g:pa"];
    }
}

- (void)setupPlayPauseButton:(NSInteger)state {
    if(state) {
        //Pause
        [self.playPauseMediaButton setTitle:@"Play" forState:UIControlStateNormal];
        self.playPauseMediaButton.tag = 0;
    }
    else {
        //Play
        [self.playPauseMediaButton setTitle:@"Pause" forState:UIControlStateNormal];
        self.playPauseMediaButton.tag = 1;
    }
}

- (IBAction)nextTrack:(id)sender {
    [self.server sendString:@"g:nt"];
}

- (IBAction)shuffle:(id)sender {
    [self.server sendString:@"g:sh"];
}

- (IBAction)volume:(UISlider*)sender {
    [self.server sendString:[NSString stringWithFormat:@"h:%f", sender.value]];
}

- (void)clickBoardServer:(ClickBoardServer *)server didAcceptString:(NSString *)string {
    @try {
        NSData *ourData = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:ourData options:NSJSONReadingAllowFragments error:nil];
        
        NSString *type = data[@"type"];
        
        if([type isEqualToString:@"cp"]) {
            //Currently Playing
            NSNumber *playState = data[@"playState"];
            NSNumber *volume = data[@"volume"];
            NSString *name = data[@"name"];
            NSString *artist = data[@"artist"];
            NSString *album = data[@"album"];
            
            if(![playState isKindOfClass:[NSNull class]]) {
                [self setupPlayPauseButton:[playState integerValue]];
            }
            
            if(![volume isKindOfClass:[NSNull class]]) {
                self.mediaVolumeSlider.value = [volume floatValue];
            }
            else {
                self.mediaVolumeSlider.value = 50;
            }
            
            if(![name isKindOfClass:[NSNull class]]) {
                self.mediaTitleLabel.text = name;
            }
            else {
                self.mediaTitleLabel.text = @"";
            }
            
            if(![artist isKindOfClass:[NSNull class]]) {
                self.mediaArtistLabel.text = artist;
            }
            else {
                self.mediaArtistLabel.text = @"";
            }
            
            if(![album isKindOfClass:[NSNull class]]) {
                self.mediaAlbumLabel.text = album;
            }
            else {
                self.mediaAlbumLabel.text = @"";
            }
        }
        else if([type isEqualToString:@"windows"]) {
            //List of open windows
            NSArray *windowsData = data[@"windows"];
            NSMutableArray *windows = [NSMutableArray array];
            if(![windowsData isKindOfClass:[NSNull class]]) {
                for (NSDictionary *windowData in windowsData) {
                    Window *window = [Window windowFromDictionary:windowData];
                    if(window) {
                        [windows addObject:window];
                    }
                }
            }
            self.windows = [windows sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(id obj1, id obj2) {
                Window *window1 = obj1;
                Window *window2 = obj2;
                return [window1.title compare:window2.title];
            }];
            
            [self.windowsTableView reloadData];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
        
    }
}

- (IBAction)appsSettings:(UIButton *)sender {
    [self.upperScrollView scrollRectToVisible:CGRectMake(sender.tag * self.upperScrollView.frame.size.width, 0, self.upperScrollView.frame.size.width, self.upperScrollView.frame.size.height) animated:YES];
    if(!sender.tag) {
        sender.tag = 1;
        [sender setBackgroundImage:[UIImage imageNamed:@"settings1.png"] forState:UIControlStateNormal];
    }
    else {
        sender.tag = 0;
        [sender setBackgroundImage:[UIImage imageNamed:@"settings2.png"] forState:UIControlStateNormal];
    }
}

- (void)addLayout:(NSString *)name withIndex:(NSInteger)index toAlertController:(UIAlertController *)alertController {
    UIAlertAction *layoutAction = [UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        AppsView appsView = 400 +  index;
        [ClickBoardConstants setAppsView:appsView];
        [self setupApps];
        [self.widgets scrollRectToVisible:CGRectMake(4 * self.widgets.frame.size.width, 0, self.widgets.frame.size.width, self.widgets.frame.size.height) animated:YES];
    }];
    [alertController addAction:layoutAction];
}

- (IBAction)appsView:(UIButton *)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Change Apps View Layout" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [self addLayout:@"2x1" withIndex:0 toAlertController:actionSheet];
    [self addLayout:@"3x2" withIndex:1 toAlertController:actionSheet];
    [self addLayout:@"4x2" withIndex:2 toAlertController:actionSheet];
    [self addLayout:@"3x4" withIndex:3 toAlertController:actionSheet];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [actionSheet addAction:cancel];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if(self.shouldNotOpenAlert) {
        return;
    }
    if(self.alertView) {
        [self.alertView dismiss];
        self.alertView = nil;
    }
    
    if(size.height > size.width) {
        //Portrait
        UIImage* rotatedImage = [UIImage imageWithCGImage:self.backgroundView.image.CGImage scale:1.0 orientation:UIImageOrientationUp];
        self.backgroundView.image = rotatedImage;
        self.cancelTouches = NO;
        self.touchpadView.hidden = YES;
        self.portraitView.hidden = NO;
    }
    else {
        //Lanscape - start trackpading
        UIImage* rotatedImage = [UIImage imageWithCGImage:self.backgroundView.image.CGImage scale:1.0 orientation:UIImageOrientationRight];
        self.backgroundView.image = rotatedImage;
        self.cancelTouches = YES;
        self.touchpadView.hidden = NO;
        self.portraitView.hidden = YES;
        [self.keyboardView resignFirstResponder:YES];
        if(![ClickBoardConstants rotatedBefore]) {
            MODropAlertView *rotateView = [[MODropAlertView alloc]initDropAlertWithTitle:@"Trackpad" description:@"Your device has rotated, activating trackpad mode. Use your finger to control your mouse and the volume buttons as mouse buttons" okButtonTitle:@"OK"];
            rotateView.tag = -2;
            rotateView.delegate = self;
            [rotateView show];
        }
    }
}

- (IBAction)helpActions:(id)sender {
    MODropAlertView *alertView = [[MODropAlertView alloc]initDropAlertWithTitle:@"Action" description:@"From this panel you can lock, shut down, restart or hibernate your PC from your iPhone" okButtonTitle:@"OK"];
    alertView.tag = -3;
    alertView.delegate = self;
    [alertView show];
}

- (IBAction)helpMedia:(id)sender {
    MODropAlertView *alertView = [[MODropAlertView alloc]initDropAlertWithTitle:@"Media" description:@"From this panel you can control iTunes on your PC from your iPhone" okButtonTitle:@"OK"];
    alertView.tag = -3;
    alertView.delegate = self;
    [alertView show];
}

- (IBAction)helpPowerpoint:(id)sender {
    MODropAlertView *alertView = [[MODropAlertView alloc]initDropAlertWithTitle:@"Powerpoint" description:@"From this panel you can launch control PowerPoint on your PC from your iPhone" okButtonTitle:@"OK"];
    alertView.tag = -3;
    alertView.delegate = self;
    [alertView show];
}

- (IBAction)helpApps:(id)sender {
    MODropAlertView *alertView = [[MODropAlertView alloc]initDropAlertWithTitle:@"Apps" description:@"From this panel you can launch apps on your PC from your iPhone" okButtonTitle:@"OK"];
    alertView.tag = -3;
    alertView.delegate = self;
    [alertView show];
}

- (IBAction)helpAppsOpener:(id)sender {
    MODropAlertView *alertView = [[MODropAlertView alloc]initDropAlertWithTitle:@"Open Windows" description:@"From this panel you can bring forward or close currently open windows" okButtonTitle:@"OK"];
    alertView.tag = -3;
    alertView.delegate = self;
    [alertView show];
}

- (NSArray *)windows {
    if(!_windows) {
        _windows = [NSArray array];
    }
    return _windows;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section < self.windows.count) {
        Window *window = self.windows[indexPath.section];
        [self.server sendString:[NSString stringWithFormat:@"w:%@", window.pid]];
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint p = [gestureRecognizer locationInView:self.windowsTableView];
    
    NSIndexPath *indexPath = [self.windowsTableView indexPathForRowAtPoint:p];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan && indexPath) {
        if(indexPath.section < self.windows.count) {
            MODropAlertView *alertView = [[MODropAlertView alloc]initDropAlertWithTitle:@"Close" description:@"This will close the program on your PC" okButtonTitle:@"Cancel" cancelButtonTitle:@"Close"];
            alertView.tag = 100 + indexPath.section;
            alertView.delegate = self;
            [alertView show];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.windows.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [UIView new];
    [v setBackgroundColor:[UIColor clearColor]];
    return v;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(indexPath.section < self.windows.count) {
        Window *window = self.windows[indexPath.section];
        cell.textLabel.text = window.title;
    }
    cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.backgroundView.alpha = 0.5;
    cell.layer.cornerRadius = 15.0;
    cell.layer.masksToBounds = YES;
    cell.clipsToBounds = YES;
    self.windowsTableView.layer.cornerRadius = 5.0;
    [self.windowsTableView setClipsToBounds:YES];
    return cell;
}

@end
