//
//  DetailViewController.m
//  R5ProObjectiveCExamples
//
//  Created by David Heimann on 6/5/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

#import "DetailViewController.h"
#import "BaseTest.h"
#import "Testbed.h"
#import "Home.h"

@interface DetailViewController ()

@property (weak) IBOutlet UITextField* hostText;
@property (weak) IBOutlet UITextField* portText;
@property (weak) IBOutlet UITextField* stream1Text;
@property (weak) IBOutlet UITextField* stream2Text;
@property (weak) IBOutlet UISwitch* debugSwitch;
@property (weak) IBOutlet UISwitch* videoSwitch;
@property (weak) IBOutlet UISwitch* audioSwitch;

@property (weak) IBOutlet UILabel* licenseText;
@property (weak) IBOutlet UIButton* licenseButton;

@property BaseTest* r5ViewController;

@end

@implementation DetailViewController

#pragma mark - IBActions

-(IBAction) onChangeLicense:(id)sender{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Red5 Pro SDK" message:@"Enter In Your SDK License" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField* field = alert.textFields[0];
        NSString* entry = field.text;
        
        if( ![entry isEqualToString:@""] ){
            [Testbed setLicenseKey:entry];
            _licenseText.text = entry;
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Enter SDK License";
        textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

-(IBAction) onStream1NameChange:(id)sender{
    [Testbed setStream1Name: _stream1Text.text];
}
-(IBAction) onStream2NameChange:(id)sender{
    [Testbed setStream2Name: _stream2Text.text];
}
-(IBAction) onStreamNameSwap:(id)sender{
    [Testbed setStream1Name: _stream2Text.text];
    [Testbed setStream2Name: _stream1Text.text];
    _stream1Text.text = [Testbed parameters][@"stream1"];
    _stream2Text.text = [Testbed parameters][@"stream2"];
}
-(IBAction) onHostChange:(id)sender{
    [Testbed setHost: _hostText.text];
}
-(IBAction) onPortChange:(id)sender{
    [Testbed setServerPort: _portText.text];
}
-(IBAction) onDebugChange:(id)sender{
    [Testbed setDebug: _debugSwitch.isOn];
}
-(IBAction) onVideoChange:(id)sender{
    [Testbed setVideo: _videoSwitch.isOn];
}
-(IBAction) onAudioChange:(id)sender{
    [Testbed setAudio: _audioSwitch.isOn];
}

#pragma mark - Base Methods

- (void)configureView {
    // Update the user interface for the detail item.
    
    _shouldAutorotate = YES;
    _supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    
    _hostText.text = [Testbed parameters][@"host"];
    //_portText.text = [Testbed parameters][@"server_port"];
    _stream1Text.text = [Testbed parameters][@"stream1"];
    _stream2Text.text = [Testbed parameters][@"stream2"];
    
    _hostText.delegate = self;
    //_portText.delegate = self;
    _stream1Text.delegate = self;
    _stream2Text.delegate = self;
    
    [_debugSwitch setOn:[[Testbed parameters][@"debug_view"] boolValue] animated: NO];
    [_videoSwitch setOn:[[Testbed parameters][@"video_on"] boolValue] animated: NO];
    [_audioSwitch setOn:[[Testbed parameters][@"audio_on"] boolValue] animated: NO];
    
    NSString* licenseKey = [Testbed parameters][@"license_key"];
    _licenseText.text = licenseKey == nil || [licenseKey isEqualToString:@""] ? @"No License Found" : licenseKey;
    
    if(self.detailItem != nil){
        
        if(self.detailItem[@"description"] != nil){
            
            UIBarButtonItem* navButton = [[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStylePlain target:self action:@selector(showInfo)];
            navButton.imageInsets = UIEdgeInsetsMake(10, 10, 10, 10);
            
            [self navigationItem].rightBarButtonItem = navButton;
        }
        
        [Testbed setLocalOverrides:_detailItem[@"LocalProperties"]];
        
        NSString* className = _detailItem[@"class"];
        Class mClass = NSClassFromString(className);
        
        //only add this view if it isn't HOME
        if( mClass != Home.class ){
            _r5ViewController  = [[mClass alloc] init];
            
            [self addChildViewController:_r5ViewController];
            [self.view addSubview:_r5ViewController.view];
            
            //r5ViewController.view.autoresizesSubviews = false
            //r5ViewController.view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth];
        }
        
    }
}

-(void) showInfo{
    UIAlertView* alert = [[UIAlertView alloc] init];
    alert.title = @"Info";
    alert.message = _detailItem[@"description"];
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return NO;
}

-(void) viewWillDisappear:(BOOL)animated{
    
    [self closeCurrentTest];
}

-(void) closeCurrentTest{
    
    if( _r5ViewController != nil ){
        [_r5ViewController closeTest];
    }
    _r5ViewController = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    self.navigationController.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(NSDictionary *)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
//        [self configureView];
    }
}


@end
