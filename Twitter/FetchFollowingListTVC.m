//
//  FetchFollowingTVC.m
//  
//
//  Created by nitesh.vi on 23/08/17.
//
//

#import "FetchFollowingListTVC.h"
#import <TwitterKit/TwitterKit.h>
#import "TwitterFetcher.h"

@interface FetchFollowingListTVC ()
@property (strong, nonatomic) NSString *nextCursor;
@end

@implementation FetchFollowingListTVC

static NSString *friendsListEndpoint = @"https://api.twitter.com/1.1/friends/list.json";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchFollowingList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchFollowingList {
    [self fetchFollowingListStartingFromCursor:@"-1"];
}

- (void)refreshFollowingList {
    [self fetchFollowingListStartingFromCursor:@"-1"];
}

- (void)fetchFollowingListStartingFromCursor:(NSString *)cursor {
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    NSString *userID = store.session.userID;
    
    NSDictionary *params = @{@"id" : userID, @"cursor" : cursor};
    
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:friendsListEndpoint parameters:params error:&clientError];
    
    if (request) {
        dispatch_queue_t fetchFollowingListQ = dispatch_queue_create("Following List Fetcher", NULL);
        dispatch_async(fetchFollowingListQ, ^{
                [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    if (data) {
                        NSError *jsonError;
                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                        NSLog(@"%@", json);
                        self.nextCursor = [NSString stringWithFormat:@"%@",[json valueForKey:TWITTER_NEXT_CURSOR]];
                        NSMutableArray *followingList = [json valueForKeyPath:TWITTER_USER];
                        if (!self.followingList || [cursor isEqualToString:@"-1"])
                        {
                            self.followingList = [[NSMutableArray alloc] init];
                        }
                        [self.followingList addObjectsFromArray:followingList];
                        [self.refreshControl endRefreshing];
                        [self.tableView reloadData];
                        
                    }
                    else {
                        NSLog(@"Error: %@", connectionError);
                    }
                }];
        });
    }
    else {
        NSLog(@"Error: %@", clientError);
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    int LastIndex = (int)[self.followingList count] - 1;
    if ([indexPath row] == LastIndex) {
        [self fetchMoreData];
    }
}

- (void)fetchMoreData {
    NSLog(@"Fetching more data");
    if ([self.nextCursor isEqualToString:@"0"] || [self.nextCursor isEqualToString:@"0"]) {
        NSLog(@"No more data");
    }
    else {
        [self fetchFollowingListStartingFromCursor:self.nextCursor];
    }
}

@end
