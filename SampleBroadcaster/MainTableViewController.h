//
//  MainTableViewController.h
//  SampleBroadcaster
//
//  Created by Mark Horgan on 29/07/2014.
//  Copyright (c) 2014 videocore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSArray * studentData;
    NSString *urlString;
    NSMutableData *responseData;
    NSDictionary *dict;
    NSArray *jsonData;

}

@property (strong, nonatomic) IBOutlet UITableView *tb;
@property(nonatomic, retain) NSArray * studentData;
-(void) createData;
@end
