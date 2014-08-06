//
//  ViewController.m
//  SampleBroadcaster
//
//  Created by James Hurley on 5/6/14.
//  Copyright (c) 2014 videocore. All rights reserved.
//

#import "ViewController.h"

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
- (IBAction)btnConnectTouch:(id)sender {
    NSUserDefaults *sURL = [NSUserDefaults standardUserDefaults];
    urlString = [sURL stringForKey:@"sURL"];

    if([self.btnConnect.titleLabel.text isEqualToString:@"Connect"]) {
        
        NSString* rtmpUrl = [NSString stringWithFormat:@"rtmp://%@:1935/live/myStream", urlString];
        NSLog(@"rtmp url is: %@", rtmpUrl);
        [self.btnConnect setTitle:@"Connecting..." forState:UIControlStateNormal];
        
        //test the stream to see which one is active
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1935/live/myStream/playlist.m3u8", urlString]];
        NSURLRequest *request = [NSURLRequest requestWithURL: url];
        NSHTTPURLResponse *response;
        [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: nil];
        if ([response respondsToSelector:@selector(allHeaderFields)]) {
            NSDictionary *dictionary = [response allHeaderFields];
            NSLog(@"Test %@",[dictionary description]);
            if ([[dictionary objectForKey:@"Content-Length"] intValue] >= 151) {
                NSLog(@"live is in use, try live2");
                rtmpUrl = [NSString stringWithFormat:@"rtmp://%@:1935/live2/myStream", urlString];
            }
//            } else if ([[dictionary objectForKey:@"Content-Length"] intValue] <=100){
//                NSLog(@"live is in free to use");
//            }
            
            //if content-length >= 150 then the stream is active, test next stream/ wowza application name (e.g. live, live2, live3 etc)
            //if content-length <= 100 then stream is inactive so broadcast to it.
        }
        
        _sampleGraph.reset(new videocore::sample::SampleGraph([self](videocore::sample::SessionState state){
            [self connectionStatusChange:state];
        }));
    
        
        _sampleGraph->setPBCallback([=](const uint8_t* const data, size_t size) {
            [self gotPixelBuffer: data withSize: size];
        });
        
        float scr_w = 720;
        float scr_h = 1280;
        
        _sampleGraph->startRtmpSession([rtmpUrl UTF8String], scr_w, scr_h, 500000 /* video bitrate */, 15 /* video fps */);
    }
    else if ( [self.btnConnect.titleLabel.text isEqualToString:@"Connected"]) {
        // disconnect
        _sampleGraph.reset();
        [self.btnConnect setTitle:@"Connect" forState:UIControlStateNormal];

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
@end
