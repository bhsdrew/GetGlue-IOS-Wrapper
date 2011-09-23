//
//  GetGlue_WrapperViewController.m
//  GetGlue Wrapper
//
//  Created by Andrew Fernandez on 6/9/11.
//  Copyright 2011 IronsoftStudios.com All rights reserved.
//

#import "GetGlue_WrapperViewController.h"
#import "GetGlue.h"
@implementation GetGlue_WrapperViewController
@synthesize GetGluetest;
- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    GetGluetest = [GetGlue alloc];
    [GetGluetest setDelegate:self];
    
    //[GetGluetest initiateGetGlue];
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"GGAccessTokenKey"] 
        && [[NSUserDefaults standardUserDefaults] stringForKey:@"GGAccessTokenSecret"] )  {
        GetGluetest.accessToken.key = [[NSUserDefaults standardUserDefaults] stringForKey:@"GGAccessTokenKey"] ;
        GetGluetest.accessToken.secret = [[NSUserDefaults standardUserDefaults] objectForKey:@"GGAccessTokenSecret"];
        GetGluetest.loggedinuser = [[NSUserDefaults standardUserDefaults] objectForKey:@"GGLoggedInUser"];
        [self finishedAuthorizingUser];
    }
    else{
       [GetGluetest initiateGetGlue]; 
    }
    
    
    
}
- (void)finishedRetrievingApiError:(NSError *)error{
    NSLog(@"error:%@",[error description]);
    [GetGluetest initiateGetGlue];
}

- (void)finishedAuthorizingUser{
    
    NSLog(@"Finished Auth");
    NSLog(@"%@",[GetGluetest loggedinuser]);
    /****************Check-in Methods ********************/
    
    //[GetGluetest userAddCheckInForObjectId:@"http://thetvdb.com/?id=72449&tab=series" withSource:@"http://rnew.de" fromApp:@"Rnewde" andComment:@"I can always rely on Stargate"];
    /*
    [GetGluetest userRemoveCheckInForObjectId:@"http://thetvdb.com/?tab=series&id=72449&lid=7" atTimeStamp:@"2011-08-14T15:55:31Z"];
    
    [GetGluetest getAllUserCheckInsForObjectId:@"http://thetvdb.com/?tab=series&id=72449&lid=7"];
    
    [GetGluetest getLastUserCheckInForObjectId:@"http://thetvdb.com/?tab=series&id=72449&lid=7"];
    
    [GetGluetest getUserCheckinHistoryForObjectId:@"tv_shows/stargate_sg_1"]; //MUST BE THEIR ID
    */
    
    /*****************User Methods***********************/
    //[GetGluetest addUserVisitToObjectId:@"http://thetvdb.com/?tab=series&id=72449&lid=7" withSource:@"http://rnew.de" fromApp:@"Rnewde"];
    //[GetGluetest addUserLikeToObjectId:@"http://thetvdb.com/?tab=series&id=72449&lid=7" withSource:@"http://rnew.de" fromApp:@"Rnewde" withComment:@"I can always rely on Stargate"];
    
    //[GetGluetest addUserFavoriteToObjectId:@"http://thetvdb.com/?tab=series&id=72449&lid=7" withSource:@"http://rnew.de" fromApp:@"Rnewde" withComment:@"I can always rely on Stargate"];
    
    //[GetGluetest addUserAskFriendsToObjectId:@"http://thetvdb.com/?tab=series&id=72449&lid=7" withSource:@"http://rnew.de" fromApp:@"Rnewde" withComment:@"Test Comment"];
    //[GetGluetest removeUserInteractionForObjectId:@"tv_shows/stargate_sg_1"];
    //[GetGluetest addUserReplyToObjectId:@"tv_shows/stargate_sg_1" fromApp:@"Rnewde" inReplyToUserId:@"" withComment:@"" forCheckInTimeStamp:@""];
    //[GetGluetest removeUserReplyToObjectID:@"" inReplyToUserId:@"" withTimeStamp:@""];
    [GetGluetest getUserProfileForUserId:[GetGluetest loggedinuser] andStickersForObjectId:nil andStickersForPartner:nil]; 
    //[GetGluetest getUserFriendsForUserId:[GetGluetest loggedinuser]];
    //[GetGluetest getUserFollowersForUserId:[GetGluetest loggedinuser]];
    //[GetGluetest isUserId:[GetGluetest loggedinuser] friendsWithUserId:@"stevenray"];
    //[GetGluetest isUserId:@"" friendsWithUserId:@""];
    //[GetGluetest followUserId:@""];
    //[GetGluetest unFollowUserId:@""];
    [GetGluetest getUserInteractionsForUserId:[GetGluetest loggedinuser] inCategory:@"all"];
    //[GetGluetest getUserInteractionsForUserId:[GetGluetest loggedinuser] andObjectId:@"tv_shows/stargate_sg_1"];
    [GetGluetest getUserStreamOfType:@"all" inCategory:@"all"];
    //[GetGluetest getListOfGuruItemsForUserId:@""];
    //[GetGluetest getUserStickersForUserId:[GetGluetest loggedinuser]];
    
    /*****************User Methods***********************/     
    /*Object Methods  */
    
    //[GetGluetest getObjectforId:@"http://thetvdb.com/?id=72449&tab=series"];
    
    /*
    - (void)getUserActivityForObjectId: (NSString *)objectId forAction: (NSString *)action andTotal:(NSString *)total andNumItems:(NSString *)numItems;
    - (void)getLinksForObjectId: (NSString *)objectId;
    - (void)getRepliesForObjectId: (NSString *)objectId forUserId:(NSString *)userID;
    - (void)getSimilarObjectsForObjectId: (NSString *)objectId;
    */
    /*****************Network Methods***********************/     
    /*
    - (void)getCategories;
    - (void)getPopularItemsInCategory:(NSString *)category;
    - (void)getTopUsersInCategory:(NSString *)category;
    - (void)findObjectWithQuery:(NSString *)q;
    - (void)findUserWithQuery:(NSString *)userId;*/
}

- (void)finishedRetrievingApi:(NSDictionary *)data{
    
    NSLog(@"Delegate: %@",data); 
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
