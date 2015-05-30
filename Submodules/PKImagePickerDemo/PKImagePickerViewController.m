//
//  MyImagePickerViewController.m
//  cameratestapp
//
//  Created by pavan krishnamurthy on 6/24/14.
//  Copyright (c) 2014 pavan krishnamurthy. All rights reserved.
//

#import "PKImagePickerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "LLACircularProgressView.h"
#import "UIColor+ChillColors.h"

@interface PKImagePickerViewController ()<MBProgressHUDDelegate> {
    NSMutableData * receivedData;
    MBProgressHUD *HUD;
    NSMutableArray *json;
}

@property(nonatomic,strong) AVCaptureSession *captureSession;
@property(nonatomic,strong) AVCaptureStillImageOutput *stillImageOutput;
@property(nonatomic,strong) AVCaptureDevice *captureDevice;
@property(nonatomic,strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property(nonatomic,assign) BOOL isCapturingImage;
@property(nonatomic,strong) UIImageView *capturedImageView;
@property(nonatomic,strong) UIImagePickerController *picker;
@property(nonatomic,strong) UIView *imageSelectedView;
@property(nonatomic,strong) UIImage *selectedImage;

@end
NSMutableData *mutData;

@implementation PKImagePickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadView
{
    self.view = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.captureSession = [[AVCaptureSession alloc]init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    self.capturedImageView = [[UIImageView alloc]init];
    self.capturedImageView.frame = self.view.frame; // just to even it out
    self.capturedImageView.backgroundColor = [UIColor clearColor];
    self.capturedImageView.userInteractionEnabled = YES;
    self.capturedImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.captureVideoPreviewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.captureVideoPreviewLayer];
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (devices.count > 0) {
        self.captureDevice = devices[0];
    
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
    
        [self.captureSession addInput:input];
    
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc]init];
        NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [self.stillImageOutput setOutputSettings:outputSettings];
        [self.captureSession addOutput:self.stillImageOutput];
    
    
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
        _captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        }
        else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        _captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        }
    
    UIButton *camerabutton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2-50, CGRectGetHeight(self.view.bounds)-100, 100, 100)];
    [camerabutton setImage:[UIImage imageNamed:@"PKImageBundle.bundle/take-snap"] forState:UIControlStateNormal];
    [camerabutton addTarget:self action:@selector(capturePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [camerabutton setTintColor:[UIColor blueColor]];
    [camerabutton.layer setCornerRadius:20.0];
    [self.view addSubview:camerabutton];
    
    UIButton *flashbutton = [[UIButton alloc]initWithFrame:CGRectMake(5, 5, 30, 31)];
    [flashbutton setImage:[UIImage imageNamed:@"PKImageBundle.bundle/flash"] forState:UIControlStateNormal];
    [flashbutton setImage:[UIImage imageNamed:@"PKImageBundle.bundle/flashselected"] forState:UIControlStateSelected];
    [flashbutton addTarget:self action:@selector(flash:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flashbutton];
    
    UIButton *frontcamera = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-50, 5, 47, 25)];
    [frontcamera setImage:[UIImage imageNamed:@"PKImageBundle.bundle/front-camera"] forState:UIControlStateNormal];
    [frontcamera addTarget:self action:@selector(showFrontCamera:) forControlEvents:UIControlEventTouchUpInside];
    //[frontcamera setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.2]];
    [self.view addSubview:frontcamera];
    }
    
    UIButton *album = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-35, CGRectGetHeight(self.view.frame)-40, 27, 27)];
    [album setImage:[UIImage imageNamed:@"PKImageBundle.bundle/library"] forState:UIControlStateNormal];
    [album addTarget:self action:@selector(showalbum:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:album];
    
    UIButton *cancel = [[UIButton alloc]initWithFrame:CGRectMake(5, CGRectGetHeight(self.view.frame)-40, 32, 32)];
    [cancel setImage:[UIImage imageNamed:@"PKImageBundle.bundle/cancel"] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancel];
    
    self.picker = [[UIImagePickerController alloc]init];
    self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.picker.delegate = self;
    
    self.imageSelectedView = [[UIView alloc]initWithFrame:self.view.frame];
    [self.imageSelectedView setBackgroundColor:[UIColor clearColor]];
    [self.imageSelectedView addSubview:self.capturedImageView];
    UIView *overlayView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-60, CGRectGetWidth(self.view.frame), 60)];
    [overlayView setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:0.9]];
    [self.imageSelectedView addSubview:overlayView];
    UIButton *selectPhotoButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(overlayView.frame)-40, 20, 32, 32)];
    [selectPhotoButton setImage:[UIImage imageNamed:@"PKImageBundle.bundle/selected"] forState:UIControlStateNormal];
    [selectPhotoButton addTarget:self action:@selector(photoSelected:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView addSubview:selectPhotoButton];
    
    UIButton *cancelSelectPhotoButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 20, 32, 32)];
    [cancelSelectPhotoButton setImage:[UIImage imageNamed:@"PKImageBundle.bundle/cancel"] forState:UIControlStateNormal];
    [cancelSelectPhotoButton addTarget:self action:@selector(cancelSelectedPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView addSubview:cancelSelectPhotoButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.captureSession startRunning];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.captureSession stopRunning];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)capturePhoto:(id)sender
{
    self.isCapturingImage = YES;
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        if (imageSampleBuffer != NULL) {
            
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            UIImage *capturedImage = [[UIImage alloc]initWithData:imageData scale:1];
            self.isCapturingImage = NO;
            self.capturedImageView.image = capturedImage;
            [self.view addSubview:self.imageSelectedView];
            self.selectedImage = capturedImage;
            imageData = nil;
        }
    }];
    
    
}

-(IBAction)flash:(UIButton*)sender
{
    if ([self.captureDevice isFlashAvailable]) {
        if (self.captureDevice.flashActive) {
            if([self.captureDevice lockForConfiguration:nil]) {
                self.captureDevice.flashMode = AVCaptureFlashModeOff;
                [sender setTintColor:[UIColor grayColor]];
                [sender setSelected:NO];
            }
        }
        else {
            if([self.captureDevice lockForConfiguration:nil]) {
                self.captureDevice.flashMode = AVCaptureFlashModeOn;
                [sender setTintColor:[UIColor blueColor]];
                [sender setSelected:YES];
            }
        }
        [self.captureDevice unlockForConfiguration];
    }
}

-(IBAction)showFrontCamera:(id)sender
{
    if (self.isCapturingImage != YES) {
        if (self.captureDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0]) {
            // rear active, switch to front
            self.captureDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1];
            
            [self.captureSession beginConfiguration];
            AVCaptureDeviceInput * newInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:nil];
            for (AVCaptureInput * oldInput in self.captureSession.inputs) {
                [self.captureSession removeInput:oldInput];
            }
            [self.captureSession addInput:newInput];
            [self.captureSession commitConfiguration];
        }
        else if (self.captureDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1]) {
            // front active, switch to rear
            self.captureDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0];
            [self.captureSession beginConfiguration];
            AVCaptureDeviceInput * newInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:nil];
            for (AVCaptureInput * oldInput in self.captureSession.inputs) {
                [self.captureSession removeInput:oldInput];
            }
            [self.captureSession addInput:newInput];
            [self.captureSession commitConfiguration];
        }
        
        // Need to reset flash btn
    }
}
-(IBAction)showalbum:(id)sender
{
    [self presentViewController:self.picker animated:YES completion:nil];
    //
}

-(IBAction)photoSelected:(id)sender
{
    
        if ([self.delegate respondsToSelector:@selector(imageSelected:)]) {
//            HUD = [[MBProgressHUD alloc] initWithView:self.view];
//            [self.view addSubview:HUD];
//            HUD.dimBackground = NO;
//            HUD.delegate = self;
//            [HUD show:YES];

//            [self.delegate imageSelected:self.selectedImage];
//            UIImage *image = self.selectedImage;
            NSData* data = UIImageJPEGRepresentation(_selectedImage, 0.4f);
            PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
            
            LLACircularProgressView *progressView = [[LLACircularProgressView alloc] initProgressViewWithDummyProgress:0.0
                                                                                                        cellStatusView:self.cellStatusView];
            [self.progressViewsDictionary setObject:progressView forKey:[NSNumber numberWithInteger:self.userIdTo]];
            
            // Save the image to Parse
            
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    // The image has now been uploaded to Parse. Associate it with a new object
                    PFObject* newPhotoObject = [PFObject objectWithClassName:@"PhotoObject"];
                    [newPhotoObject setObject:imageFile forKey:@"image"];
                    
                    [newPhotoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (!error) {
                            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"http://api.iamchill.co/v1/messages/index/"]]];
                            //[request setValue:@"Chill" forHTTPHeaderField:@"User-Agent"];
                            [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"X-API-TOKEN"];

                            [request setHTTPMethod:@"POST"];
                            
                            NSURLResponse *response = nil;
                            NSError *error = nil;
                            NSString *postString = [NSString stringWithFormat:@"id_contact=%ld&id_user=%@&content=%@&type=parse",(long)_userIdTo,[[NSUserDefaults standardUserDefaults] valueForKey:@"id_user"],imageFile.url];
                            
                            //[request setValue:[NSString
                            //                   stringWithFormat:@"%lu", (unsigned long)[postString length]]
                            //forHTTPHeaderField:@"Content-length"];
                            
                            [request setHTTPBody:[postString
                                                  dataUsingEncoding:NSUTF8StringEncoding]];
                            json = [NSJSONSerialization JSONObjectWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error] options:NSJSONReadingMutableContainers error:&error];
                            NSUserDefaults *userCache = [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"group.co.getchill.chill"];
                            
                            PFPush *push = [[PFPush alloc] init];
                            NSString *message = [NSString stringWithFormat:@"📷 from %@",[userCache valueForKey:@"name"]];
                            NSDictionary *data = @{
                                                   @"alert": message,
                                                   @"type": @"Photo",
                                                   @"sound": @"default",
                                                   @"badge" : @1,
                                                   @"fromUserId": [userCache valueForKey:@"id_user"]
                                                   };

                            
                            
                            [push setChannel:[NSString stringWithFormat:@"us%li",(long)_userIdTo]];
                            [push setData:data];
                            //[push setMessage:[NSString stringWithFormat:@"%@: Send location",[userCache valueForKey:@"name"]]];
                            [push sendPushInBackground];
                            
//                            [HUD hide:YES];
//                            HUD = [[MBProgressHUD alloc] initWithView:self.view];
//                            [self.view addSubview:HUD];
//                            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
//                            
//                            // Set custom view mode
//                            HUD.mode = MBProgressHUDModeCustomView;
//                            
//                            HUD.delegate = self;
//                            HUD.labelText = @"Completed";
//                            
//                            [HUD show:YES];
//                            [HUD hide:YES afterDelay:2];
//                            sleep(2);
//                            [self dismissViewControllerAnimated:YES completion:nil];


                        }
                        else{
                            // Error
                        }
                    }];
                }
            }
            progressBlock:^(int percentDone) {
                float actualCurrentProgress = (float)percentDone / 100;
                LLACircularProgressView *currentProgressView = [self.progressViewsDictionary objectForKey:[NSNumber numberWithInteger:self.userIdTo]];
                [currentProgressView setProgress:actualCurrentProgress animated:YES];
            }];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
       // [self.imageSelectedView removeFromSuperview];
}

-(IBAction)cancelSelectedPhoto:(id)sender
{
    [self.imageSelectedView removeFromSuperview];
}

-(IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(imageSelectionCancelled)]) {
            [self.delegate imageSelectionCancelled];
        }

    }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.capturedImageView.image = self.selectedImage;
        [self.view addSubview:self.imageSelectedView];
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
