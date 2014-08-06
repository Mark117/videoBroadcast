//
//  StreamViewController.m
//  SampleBroadcaster
//
//  Created by Mark Horgan on 01/07/2014.
//  Copyright (c) 2014 videocore. All rights reserved.
//

#import "StreamViewController.h"

@interface StreamViewController ()

@end

@implementation StreamViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*******************
    Take in the data object from the table cell, this will tell which live url to use
    *******************/
    
	// Do any additional setup after loading the view, typically from a nib.
    NSUserDefaults *sURL = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [sURL stringForKey:@"sURL"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1935/live/myStream/playlist.m3u8", urlString]];
    MPMoviePlayerController *controller = [[MPMoviePlayerController alloc]
                                           initWithContentURL:url];
    self.mc = controller;
    controller.view.frame = self.view.bounds;
    [self.view addSubview:controller.view];
    [controller prepareToPlay];
    [controller play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; 
    // Dispose of any resources that can be recreated.
}


@end
