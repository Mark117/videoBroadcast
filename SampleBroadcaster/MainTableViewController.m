//
//  MainTableViewController.m
//  SampleBroadcaster
//
//  Created by Mark Horgan on 29/07/2014.
//  Copyright (c) 2014 videocore. All rights reserved.
//

#import "MainTableViewController.h"
#import "Person.h"
#import "WatchTableViewCell.h"
#import "SBJsonBase.h"
#import "SBJsonParser.h"

@interface MainTableViewController ()

@end

@implementation MainTableViewController

@synthesize studentData;

-(void) createData
{
    self.studentData = [NSArray arrayWithObjects:[[Person alloc] initWithName:@"Mark's iPhone" andAddress:@"add" andPhone:@"stuff" andImage:@"image.png"],[[Person alloc] initWithName:@"Mark's iPad" andAddress:@"addo" andPhone:@"stuffo" andImage:@"image.png"] ,[[Person alloc] initWithName:@"Other Device" andAddress:@"addy" andPhone:@"stuffy" andImage:@"image.png"] ,nil];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) viewWillAppear{
    //get active streams from DB
    NSUserDefaults *sURL = [NSUserDefaults standardUserDefaults];
    urlString = [sURL stringForKey:@"sURL"];
    NSString *URLString = [NSString stringWithFormat:@"http://%@:8888/project/selectActive.php", urlString];
    NSLog(@"URL is: %@", URLString);
    NSURL *urlJSON = [[NSURL alloc] initWithString:URLString];
    NSData* data = [NSData dataWithContentsOfURL:urlJSON];
    
    NSString *JSONString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSError *error = nil;
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    dict = [jsonParser objectWithString:JSONString error:&error];
    jsonData = [dict valueForKeyPath:@"streamers"];
    NSLog(@"JSON DATA IS: %@", jsonData);
    [self.tb reloadData];
    //streams have been returned

    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //get active streams from DB
    NSUserDefaults *sURL = [NSUserDefaults standardUserDefaults];
    urlString = [sURL stringForKey:@"sURL"];
    NSString *URLString = [NSString stringWithFormat:@"http://%@:8888/project/selectActive.php", urlString];
    NSLog(@"URL is: %@", URLString);
    NSURL *urlJSON = [[NSURL alloc] initWithString:URLString];
    NSData* data = [NSData dataWithContentsOfURL:urlJSON];
    
    NSString *JSONString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSError *error = nil;
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    dict = [jsonParser objectWithString:JSONString error:&error];
    jsonData = [dict valueForKeyPath:@"streamers"];
    NSLog(@"JSON DATA IS: %@", jsonData);
    [self.tb reloadData];
    //streams have been returned
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [jsonData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    Person * person = self.studentData[indexPath.row];
    NSDictionary *localDict=  [jsonData objectAtIndex:indexPath.row];
    
    //cell.textLabel.text = person.name;
    //cell.imageView.image = [UIImage imageNamed:person.image];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
    nameLabel.text = [localDict objectForKey:@"sname"];
    
    UILabel *ratingLabel = (UILabel *)[cell viewWithTag:105];
    //get rating for stream named person.name from DB
    ratingLabel.text = [localDict objectForKey:@"rating"];
    
    UIImageView *ratingImageView = (UIImageView *)[cell viewWithTag:102];
    //connect to stream, download frame every 10 seconds, add as user pref?
    ratingImageView.image = [UIImage imageNamed:@"image.png"];
    
    UIButton *upvote = (UIButton *)[cell viewWithTag:103];
    [upvote addTarget:self action:@selector(upvoteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *downvote = (UIButton *)[cell viewWithTag:104];
    [downvote addTarget:self action:@selector(downvoteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *morebtn = (UIButton *)[cell viewWithTag:106];
    [morebtn addTarget:self action:@selector(moreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *localDict=  [jsonData objectAtIndex:indexPath.row];
    NSLog(@"selected row %@", [localDict objectForKey:@"sname"]);
}

-(IBAction)upvoteButtonClicked:(id)sender {
    NSLog(@"upvote");
    /*
     Connect to DB, upload the user's preference, along with their device ID, so they can't
     spam votes. Also increment the rating value by 1
     
     */
}

-(IBAction)downvoteButtonClicked:(id)sender {
    NSLog(@"downvote");
    /*
     Connect to DB, upload the user's preference, along with their device ID, so they can't
     spam votes. Also decrement the rating value by 1
     
     */
}

-(IBAction)moreButtonClicked:(id)sender {
    NSLog(@"more");
    //segue to new view showing the streamer's preferences
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
    [super dealloc];
}
@end
