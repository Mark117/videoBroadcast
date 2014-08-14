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
    NSDictionary *voteDict;
    NSArray *jsonVoteData;
    NSDictionary *typeDict;
    NSArray *jsonVoteType;
}

@property (strong, nonatomic) IBOutlet UITableView *tb;
@property(nonatomic, retain) NSArray * studentData;
//@property(retain) NSArray *jsonData;
@property (retain, nonatomic) IBOutlet UITableView *button;


-(void) createData;
@end
