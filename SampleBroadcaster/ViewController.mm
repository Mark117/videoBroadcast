//
//  ViewController.m
//  SampleBroadcaster
//
//  Created by James Hurley on 5/6/14.
//  Copyright (c) 2014 videocore. All rights reserved.
//

#import "ViewController.h"
#import "SBJsonBase.h"
#import "SBJsonParser.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController () <GLKViewDelegate>
{
    GLuint _renderBuffer;
    BOOL _spinning;
}
@property (nonatomic, retain) EAGLContext* glContext;
@property (nonatomic, retain) CIContext*   ciContext;
@property (nonatomic) CIImage* ciImage;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.glContext];
    self.glkView.context = self.glContext;
    self.glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    self.ciContext = [CIContext contextWithEAGLContext:self.glContext];
    self.glkView.delegate = self;
    self.btnSpin.hidden = YES;
    _spinning = false;
    
    NSUserDefaults *sURL = [NSUserDefaults standardUserDefaults];
    [sURL setObject:@"192.168.1.16" forKey:@"sURL"];
    [sURL synchronize];
    
    NSUserDefaults *sname = [NSUserDefaults standardUserDefaults];
    [sname setObject:@"Mark Horgan" forKey:@"sname"];
    [sname synchronize];
    
    
   // NSString *deviceName = [[UIDevice currentDevice] name];
    deviceUUID = [UIDevice currentDevice].identifierForVendor.UUIDString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_btnConnect release];
    [_glkView release];
    [_btnSpin release];
    [_button release];
    [_imageView release];
    [super dealloc];
}
- (void) glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    float aspect = self.ciImage.extent.size.width / self.ciImage.extent.size.height;
    float aspect_w = aspect > 1.f ? 1.f : aspect;
    float aspect_h = aspect <= 1.f ? 1.f : aspect;
    
    rect.size.height *= [UIScreen mainScreen].scale;
    rect.size.width *= [UIScreen mainScreen].scale;
    
    CGRect nRect = rect;
    nRect.size.width /= aspect_w;
    nRect.size.height /= aspect_h;
    
    nRect.origin.x -= (nRect.size.width - rect.size.width) / 2;
    nRect.origin.y -= (nRect.size.height - rect.size.height) / 2;
    
    [self.ciContext drawImage:self.ciImage inRect:nRect fromRect:self.ciImage.extent];
    
    self.ciImage = nil;
}
- (UIImage*)screenshot
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
//    [_button setImage:image forState:UIControlStateNormal];
    
    return image;
}

- (IBAction)btnConnectTouch:(id)sender {
    NSUserDefaults *sURL = [NSUserDefaults standardUserDefaults];
    urlString = [sURL stringForKey:@"sURL"];

    if([self.btnConnect.titleLabel.text isEqualToString:@"Connect"]) {
        ////////DO DATABASE WORK - select * from streamer
        //if range of string is live, use live 2, if live2 use live 3 etc
        
        //Load the JSON db results from the server
        NSString *URLString = [NSString stringWithFormat:@"http://%@:8888/project/select.php", urlString];
        NSURL *urlJSON = [[NSURL alloc] initWithString:URLString];
        NSData* data = [NSData dataWithContentsOfURL:urlJSON];
        
        NSString *JSONString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        dict = [jsonParser objectWithString:JSONString error:&error];
        jsonData = [dict valueForKeyPath:@"streamers"];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for(NSDictionary *data in jsonData){
            [array addObject:[data objectForKey:@"url"]];
        }
        NSString * result = [array componentsJoinedByString:@""];
       // NSLog(@"jsonData is: %@", array);
        
        //cycle through the urls in the DB, find the range of string live part. if range of string is live, use live 2, if live2 use live 3 etc
        NSRegularExpression *regex =[NSRegularExpression regularExpressionWithPattern:@"\\w\\w\\w\\w\\d" options:0 error:NULL];
        NSArray *arrayOfAllMatches = [regex matchesInString:result options:0 range:NSMakeRange(0, [result length])];
        
        NSMutableArray *arrayOfURLs = [[NSMutableArray alloc] init];
        
        for (NSTextCheckingResult *match in arrayOfAllMatches) {
            NSString* substringForMatch = [result substringWithRange:match.range];
           // NSLog(@"Extracted URL: %@",substringForMatch);
            
            [arrayOfURLs addObject:substringForMatch];
        }
        
        // return non-mutable version of the array
        //live array is the array of available streams
        NSMutableArray *liveArray = [[NSMutableArray alloc] init];
        [liveArray addObject:@"live1"];
        [liveArray addObject:@"live2"];
        [liveArray addObject:@"live3"];
        [liveArray addObject:@"live4"];
        [liveArray addObject:@"live5"];
        
        //the result of the below line of code is the streams available
        [liveArray removeObjectsInArray:[NSArray arrayWithArray:arrayOfURLs]];
        
        NSLog(@"STREAMS AVAILABLE FOR USE: %@", liveArray);

        ////////////END DATABASE WORK

        //select object at index 0 for the url of the stream and Connect to the stream
        NSString* rtmpUrl = [NSString stringWithFormat:@"rtmp://%@:1935/%@/myStream", urlString, [liveArray objectAtIndex:0]];
        NSLog(@"CONNECTED TO: %@", [liveArray objectAtIndex:0]);
        
        [self.btnConnect setTitle:@"Connecting..." forState:UIControlStateNormal];
        _sampleGraph.reset(new videocore::sample::SampleGraph([self](videocore::sample::SessionState state){
            [self connectionStatusChange:state];
        }));
        _sampleGraph->setPBCallback([=](const uint8_t* const data, size_t size) {
            [self gotPixelBuffer: data withSize: size];
        });
        float scr_w = 720;
        float scr_h = 1280;
        int bitrate = 500000;
        int fps = 15;
        _sampleGraph->startRtmpSession([rtmpUrl UTF8String], scr_w, scr_h, bitrate /* video bitrate */, fps /* video fps */);
        
        [self screenshot];
        ////////DO DATABASE WORK -> upload the sname, uuid, bitrate, fps, url, active, rating
        int active = 1;
        int rating = 0;
        NSUserDefaults *sname = [NSUserDefaults standardUserDefaults];
        strname = [sname stringForKey:@"sname"];
     
        NSString *regString = [NSString stringWithFormat:@"http://%@:8888/project/register.php?sname=%@&uuid=%@&bitrate=%d&fps=%d&url=%@&active=%d&rating=%d", urlString, strname, [UIDevice currentDevice].identifierForVendor.UUIDString, bitrate, fps, rtmpUrl, active, rating];
        regString = [regString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *url = [NSURL URLWithString:regString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        NSData *urlData;
        NSURLResponse *response;
        urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:nil];
        //////END DB REGISTRATION
    }else if ( [self.btnConnect.titleLabel.text isEqualToString:@"Connected"]) {
        // disconnect from the stream
        _sampleGraph.reset();
        [self.btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
        
        NSLog(@"Stream disconnected");
        NSUserDefaults *sname = [NSUserDefaults standardUserDefaults];
        strname = [sname stringForKey:@"sname"];
        
        
        ////////DO DATABASE WORK -> drop from DB so user is no longer active
        NSString *regString = [NSString stringWithFormat:@"http://%@:8888/project/changeActive.php?uuid=%@", urlString, [UIDevice currentDevice].identifierForVendor.UUIDString];
        regString = [regString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:regString];
       // NSLog(@"drop string is: %@", url);
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        NSData *urlData;
        NSURLResponse *response;
        urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:nil];
        //////END DB STREAM ACTIVITY CHANGE
    }
    
}

-(void)fetchedData:(NSData *)responseData2 {
    NSError* error;
    if (responseData2 == nil) {
        NSLog(@"NO DATA HAS BEEN FETCHED,ERROR");
    }else{
        NSString *JSONString = [[NSString alloc] initWithData:responseData2 encoding:NSUTF8StringEncoding];
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        dict = [jsonParser objectWithString:JSONString error:&error];
        jsonData = [dict valueForKeyPath:@"streamers"];
        NSLog(@"jsonData is: %@", [[jsonData objectAtIndex:1]objectForKey:@"url"]);
        
        
    }
}


- (IBAction)btnSpinTouch:(id)sender {
    //reachability code to test for active server
    
    
    
    
    
    
    /*_spinning = !_spinning;
    if(_sampleGraph) {
        _sampleGraph->spin(_spinning);
    }*/
}

- (void) connectionStatusChange:(videocore::sample::SessionState) state
{
    NSLog(@"Connection status: %d", state);
    if(state == videocore::sample::kSessionStateStarted) {
        NSLog(@"Connected");
        [self.btnConnect setTitle:@"Connected" forState:UIControlStateNormal];
        [self.btnConnect.titleLabel sizeToFit];
        self.btnSpin.hidden = NO;
        
    } else if(state == videocore::sample::kSessionStateError || state == videocore::sample::kSessionStateEnded) {
        NSLog(@"Disconnected");
        [self.btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
        _sampleGraph.reset();
        self.btnSpin.hidden = YES;
    }
}
- (void) gotPixelBuffer: (const uint8_t* const) data withSize: (size_t) size {
    
    @autoreleasepool {
        
       
        CVPixelBufferRef pb = (CVPixelBufferRef) data;
        CVPixelBufferLockBaseAddress(pb, 1);
        CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pb];
        
        self.ciImage = ciImage;
        [self.glkView display];
        
        CVPixelBufferUnlockBaseAddress(pb, 0);

    }
}
- (IBAction)onClick:(id)sender {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
    
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    
    UIImage *copied = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"image is: %@", copied);
    //    [self screenshot];
    [_imageView setImage:copied];
    [_button setImage:copied forState:UIControlStateNormal];
}
@end
