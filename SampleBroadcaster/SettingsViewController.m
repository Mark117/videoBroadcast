//
//  SettingsViewController.m
//  SampleBroadcaster
//
//  Created by Mark Horgan on 14/08/2014.
//  Copyright (c) 2014 videocore. All rights reserved.
//

#import "SettingsViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "AVFoundation/AVAsset.h"
#import "CoreMedia/CMTime.h"
#import <MediaPlayer/MediaPlayer.h>


@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self generateImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)generateImage
{
    ///test
    
    NSURL *url = [NSURL URLWithString:@"http://192.168.1.16:1935/live2/myStream/playlist.m3u8"];
//    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:url options:nil];
//    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
//    generator.appliesPreferredTrackTransform=TRUE;
//    [asset release];
//    CMTime thumbTime = CMTimeMakeWithSeconds(0,30);
//    
//    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
//        if (result != AVAssetImageGeneratorSucceeded) {
//            NSLog(@"couldn't generate thumbnail, error:%@", error);
//        }
//        [_button setImage:[UIImage imageWithCGImage:im] forState:UIControlStateNormal];
//       // _thumbnail=[[UIImage imageWithCGImage:im] retain];
//        [generator release];
//    };
//    
//    CGSize maxSize = CGSizeMake(320, 180);
//    generator.maximumSize = maxSize;
//    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = [asset duration];
    time.value = 0;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    [_button setImage:thumbnail forState:UIControlStateNormal];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_button release];
    [_thumbnail release];
    [super dealloc];
}
@end
