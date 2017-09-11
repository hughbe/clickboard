//
//  ConnectViewController.m
//  ClickBoard
//
//  Created by Hugh Bellamy on 06/05/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "ConnectViewController.h"
#import "MODropAlertView.h"
#import "ViewController.h"
#import "MBProgressHUD.h"

@interface ConnectViewController ()

@property (strong, nonatomic) NSArray *services;
@property (strong, nonatomic) NSTimer *waitTimer;

@end

@implementation ConnectViewController

@synthesize services = _services;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.instructionsScrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3, self.instructionsScrollView.frame.size.height);
    
    CGRect frame1 = self.instructionsPageControl.frame;
    frame1.origin.x = 0;
    frame1.origin.y = self.view.frame.size.height - frame1.size.height;
    frame1.size.width = self.view.frame.size.width;
    self.instructionsPageControl.frame = frame1;
    
    CGRect frame2 = self.instructionsScrollView.frame;
    frame2.origin.x = 0;
    frame2.size.width = self.view.frame.size.width;
    self.instructionsScrollView.frame = frame2;
    
    CGRect frame3 = self.tableView.frame;
    frame2.origin.x = 0;
    frame3.size.height = frame2.origin.y;
    frame2.size.width = self.view.frame.size.width;
    self.tableView.frame = frame3;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startServer];
    [self setupBackground];
    [self stopWaitTimer];
}

- (void)startWaitTimer {
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.label.text = @"Connecting";
    
    self.waitTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(failedToConnect:) userInfo:nil repeats:NO];
}

- (void)stopWaitTimer {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.waitTimer invalidate];
    self.waitTimer = nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.instructionsPageControl.currentPage = page;
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
    
    self.backgroundImageView.image = backgroundImage;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(![ClickBoardConstants ranBefore]) {
        MODropAlertView *installDropAlertView = [[MODropAlertView alloc]initDropAlertWithTitle:@"Install the App" description:@"To use ClickBoard you need to install the PC application which can be found at: www.clickboardapp.com" okButtonTitle:@"Done"];
        installDropAlertView.delegate = self;
        installDropAlertView.tag = -1;
        [installDropAlertView show];
    }
}

- (void)clickBoardServer:(ClickBoardServer *)server lostConnection:(NSDictionary *)errorDict {
    [self.navigationController popViewControllerAnimated:YES];
    [self startServer];
    
    MODropAlertView *lostConnectionDropAlertView = [[MODropAlertView alloc]initDropAlertWithTitle:@"Lost Connection" description:@"ClickBoard has been disconnected from your PC. Please reconnect." okButtonTitle:@"OK"];
    lostConnectionDropAlertView.delegate = self;
    [lostConnectionDropAlertView show];
}

- (void)clickBoardServer:(ClickBoardServer *)server didConnectToPCType:(PCType)type {
    [ClickBoardConstants setPCType:type];
}

- (void)clickBoardServer:(ClickBoardServer *)server didNotStart:(NSDictionary *)errorDict {
    [self startServer];
    MODropAlertView *lostConnectionDropAlertView = [[MODropAlertView alloc]initDropAlertWithTitle:@"Error Connecting" description:@"Please check your network status and try again." okButtonTitle:@"OK"];
    lostConnectionDropAlertView.delegate = self;
    [lostConnectionDropAlertView show];
    NSLog(@"Server did not start: %@", errorDict);
}

- (void)clickBoardServer:(ClickBoardServer *)server didFindServices:(NSArray *)services {
    self.services = [services copy];
}

- (void)clickBoardServer:(ClickBoardServer *)server didCompleteRemoteConnectionWithService:(NSNetService *)service {
    [self stopWaitTimer];
    ViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ClickBoard"];
    viewController.server = self.server;
    self.server.dataStreamDelegate = viewController;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)startServer {
    [self stopServer];
    self.server = [[ClickBoardServer alloc]initWithProtocol:@"_ClickBoard._tcp." delegate:self];
    [self.server searchForServicesOfType:@"_ClickBoard._tcp"];
}

- (void)stopServer {
    self.server.dataStreamDelegate = nil;
    self.server.delegate = nil;
    [self.server stop];
    self.server = nil;
}

- (NSArray *)services {
    if(!_services) {
        _services = [NSArray array];
    }
    return _services;
}

- (void)setServices:(NSArray *)services {
    _services = services;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewAutomaticDimension];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.services.count + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if(indexPath.row < self.services.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        NSNetService *service = self.services[indexPath.row];
        cell.textLabel.text = [service.name stringByReplacingOccurrencesOfString:@"_" withString:@""];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"More" forIndexPath:indexPath];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row < self.services.count) {
        [self startWaitTimer];
        NSNetService *service = self.services[indexPath.row];
        service.delegate = self.server;
        [service resolveWithTimeout:0];
    }
}

- (void)failedToConnect:(NSTimer *)timer {
    [self stopWaitTimer];
    
    [self clickBoardServer:self.server didNotStart:nil];
}

- (void)alertViewPressButton:(MODropAlertView *)alertView buttonType:(DropAlertButtonType)buttonType {
    [alertView dismiss];
    if(alertView.tag == -1) {
        //First run
        [ClickBoardConstants setRanBefore:YES];
    }
}

- (IBAction)QRCode:(id)sender {
    ZBarReaderViewController *codeReader = [ZBarReaderViewController new];
    codeReader.readerDelegate=self;
    codeReader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = codeReader.scanner;
    [scanner setSymbology: ZBAR_I25 config: ZBAR_CFG_ENABLE to: 0];
    
    [self presentViewController:codeReader animated:YES completion:nil];
}

- (IBAction)Text:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Enter IP Addresss" message:@"A manual method of connecting to your PC - it can be found by clicking the ""QR Code"" button in the PC app" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Connect", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex != alertView.cancelButtonIndex) {
        //Connect
        NSString *text = [alertView textFieldAtIndex:0].text;
        if(text.length) {
            self.waitTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(failedToConnect:) userInfo:nil repeats:NO];
            [self.server connectToAddress:[text UTF8String] port:6293 service:[[NSNetService alloc]init]];
        }
    }
}

- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    //  get the decode results
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // just grab the first barcode
        break;
    
    // showing the result on textview
    self.waitTimer = [NSTimer scheduledTimerWithTimeInterval:7.50 target:self selector:@selector(failedToConnect:) userInfo:nil repeats:NO];
    [self.server connectToAddress:[symbol.data UTF8String] port:6293 service:[[NSNetService alloc]init]];
    
    // dismiss the controller
    [reader dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
@end
