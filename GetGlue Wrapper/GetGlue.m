//
//  GetGlue.m
//  GetGlue Wrapper
//
//  Created by Andrew Fernandez on 6/9/11.
//  Copyright 2011 IronsoftStudios.com All rights reserved.
//

#import "GetGlue.h"
#import "GetGlueDialog.h"
#import "JSON.h"

#define GetGlueSecret          @""
#define GetGlueKey             @""


@implementation GetGlue
@synthesize requestToken,accessToken,authorizeParams,delegate,loggedinuser;


-(void) dealloc{
    [requestToken release];
    [authorizeParams release];
    [accessToken release];
    [super dealloc];
}

//BEGIN OAUTH REQUEST TOKEN
- (void) initiateGetGlue{
    
    //create oauth consumer for request token
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:GetGlueKey
                                                    secret:GetGlueSecret];
    
    //set request token url
    NSURL *url = [NSURL URLWithString:GetGlueRequestTokenUrl];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:nil   // we don't have a Token yet
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    //create an oauth parameter for callingback to the appitself in order to capture the token data
    [request setOAuthParameterName:@"oauth_callback" withValue:@"GetGluewrap://GetGluecallback"];
    
    //request type is post
    [request setHTTPMethod:@"GET"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
    [consumer release];
    [request release];
}


- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    // NSLog(@"%@",responseBody);
    requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?oauth_token=%@&style=mobile&oauth_callback=GetGluewrap://GetGluecallback",GetGlueAuthorizeUrl,requestToken.key]];
    
    //NSLog(@"token:%@",requestToken.key);
    //NSLog(@"url:%@",url);
    
    //fire login dialog to authorize app
    GetGlueDialog *dialog;
    dialog = [[GetGlueDialog alloc ] initWithUrl:url GetGlueClass:self];
    [responseBody release];
    
    
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    //oauth error checking
    //NSLog(@"%@",[error description]);
}

//END OAUTH REQUEST TOKEN


//BEGIN OAUTH ACCESS TOKEN

- (void) authorizeUser{
    
    //prepare returned credentials into a nsdictionary
    //NSLog(@"%@",self.authorizeParams);
    //NSDictionary *querystring = [self parseQueryString:self.authorizeParams];
    
    //create oauth consumer for request token
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:GetGlueKey
                                                    secret:GetGlueSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:GetGlueAccessTokenUrl];
    
    //NSLog(@"%@",[url absoluteString]);
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:requestToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //NSLog(@"%@",[querystring objectForKey:@"oauth_token"]);
    //NSLog(@"%@",[querystring objectForKey:@"oauth_verifier"]);
    //[request setOAuthParameterName:@"oauth_token" withValue:[querystring objectForKey:@"oauth_token"]];
    //[request setOAuthParameterName:@"oauth_verifier" withValue:[querystring objectForKey:@"oauth_verifier"]];
    
    //request type is post
    [request setHTTPMethod:@"GET"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
    [consumer release];
    [request release];
    
}
- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
    
    //NSLog(@"token:%@",accessToken.key);
    //NSLog(@"token:%@",accessToken.secret);
    [[NSUserDefaults standardUserDefaults] setObject:accessToken.key forKey:@"GGAccessTokenKey"];
    [[NSUserDefaults standardUserDefaults] setObject:accessToken.secret forKey:@"GGAccessTokenSecret"];
    
    //NSLog(@"body:%@",responseBody);
    NSArray *pairs = [responseBody componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if ([[elements objectAtIndex:0] isEqualToString:@"glue_userId"]) {
            loggedinuser = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[NSUserDefaults standardUserDefaults] setObject:loggedinuser forKey:@"GGLoggedInUser"];
        } 
    }
    
    [responseBody release];
    [delegate finishedAuthorizingUser];
    
}
- (void) logout{
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GGAccessTokenKey"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GGAccessTokenSecret"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GGLoggedInUser"];
    
    
}
- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
}

- (void)doApiCallForUrl: (NSString *)url withRequiredParams:(NSDictionary *)reqparams andOptionalParams:(NSDictionary *)optparams{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:GetGlueKey
                                                    secret:GetGlueSecret];
    
    //set access token url
    NSURL *apiurl = [NSURL URLWithString:url];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:apiurl
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    int reqparamscount = [reqparams count];
    int optparamscount = [optparams count];
    int totalparams = reqparamscount + optparamscount;
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:totalparams];
    
    for(NSString *key in reqparams){
        
        OARequestParameter *parameter = [[OARequestParameter alloc] initWithName:key value:[reqparams objectForKey:key]];
        [params addObject:parameter];
        [parameter release];
        
    }
    for(NSString *key in optparams){
        if([optparams objectForKey:key]){
            OARequestParameter *parameter = [[OARequestParameter alloc] initWithName:key value:[optparams objectForKey:key]];
            [params addObject:parameter];
            [parameter release];
        }
        
    }
    [request setParameters:params];
    //request type is post
    
    [request setHTTPMethod:@"GET"];
    
    //NSLog(@"%@",[[request URL] absoluteString]);
    
    //OAAsynchronousDataFetcher *asfetcher = [[[OAAsynchronousDataFetcher alloc] initWithRequest:request delegate:self didFinishSelector:@selector(apiTicket:didFinishWithData:) didFailSelector:@selector(apiTicket:didFailWithError:)] autorelease];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    //[asfetcher start];
    [consumer release];
    [request release]; 
}


/*************** User API Calls **************************/


/*Check-in Methods */

- (void)userAddCheckInForObjectId: (NSString *)objectId withSource:(NSString *)source fromApp:(NSString *)app andComment:(NSString *)comment{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:GetGlueKey
                                                    secret:GetGlueSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://api.getglue.com/v2/user/addCheckin"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:5];
    OARequestParameter *object_Id = [[OARequestParameter alloc] initWithName:@"objectId" value:objectId];
    [params addObject:object_Id];
    [object_Id release];
    
    OARequestParameter *_source = [[OARequestParameter alloc] initWithName:@"source" value:source];
    [params addObject:_source];
    [_source release];
    
    OARequestParameter *_app = [[OARequestParameter alloc] initWithName:@"app" value:app];
    [params addObject:_app];
    [_app release];
    
    
    
    if(comment){
        OARequestParameter *_comment = [[OARequestParameter alloc] initWithName:@"comment" value:comment];
        [params addObject:_comment];
        [_comment release];
    }
    
    OARequestParameter *format = [[OARequestParameter alloc] initWithName:@"format" value:@"json"];
    [params addObject:format];
    [format release];
    
    OARequestParameter *service = [[OARequestParameter alloc] initWithName:@"service" value:@"twitter,facebook"];
    [params addObject:service];
    [service release];
    
    
    [request setParameters:params];
    //request type is post
    
    [request setHTTPMethod:@"GET"];
    
    //NSLog(@"%@",[[request URL] absoluteString]);
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];  
    
}
- (void)userRemoveCheckInForObjectId: (NSString *)objectId atTimeStamp:(NSString *)timestamp{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:GetGlueKey
                                                    secret:GetGlueSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://api.getglue.com/v2/user/removeCheckin"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:3];
    OARequestParameter *object_Id = [[OARequestParameter alloc] initWithName:@"objectId" value:objectId];
    [params addObject:object_Id];
    [object_Id release];
    
    OARequestParameter *_timestamp = [[OARequestParameter alloc] initWithName:@"timestamp" value:timestamp];
    [params addObject:_timestamp];
    [_timestamp release];
    
    
    OARequestParameter *format = [[OARequestParameter alloc] initWithName:@"format" value:@"json"];
    [params addObject:format];
    [format release];
    
    [request setParameters:params];
    //request type is post
    
    [request setHTTPMethod:@"GET"];
    
    //NSLog(@"%@",[[request URL] absoluteString]);
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];  
}

//param action=checkedIn
- (void)getAllUserCheckInsForObjectId: (NSString *)objectId {
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:GetGlueKey
                                                    secret:GetGlueSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://api.getglue.com/v2/object/users"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:3];
    if(objectId){
        OARequestParameter *object_Id = [[OARequestParameter alloc] initWithName:@"objectId" value:objectId];
        [params addObject:object_Id];
        [object_Id release];
    }
    
    OARequestParameter *action = [[OARequestParameter alloc] initWithName:@"action" value:@"checkedIn"];
    [params addObject:action];
    [action release];
    
    
    OARequestParameter *format = [[OARequestParameter alloc] initWithName:@"format" value:@"json"];
    [params addObject:format];
    [format release];
    
    [request setParameters:params];
    //request type is post
    
    [request setHTTPMethod:@"GET"];
    
    //NSLog(@"%@",[[request URL] absoluteString]);
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];   
}

//param action=lastCheckedIn
- (void)getLastUserCheckInForObjectId: (NSString *)objectId{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:GetGlueKey
                                                    secret:GetGlueSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://api.getglue.com/v2/object/users"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:3];
    if(objectId){
        OARequestParameter *object_Id = [[OARequestParameter alloc] initWithName:@"objectId" value:objectId];
        [params addObject:object_Id];
        [object_Id release];
    }
    
    OARequestParameter *action = [[OARequestParameter alloc] initWithName:@"action" value:@"lastCheckedIn"];
    [params addObject:action];
    [action release];
    
    
    OARequestParameter *format = [[OARequestParameter alloc] initWithName:@"format" value:@"json"];
    [params addObject:format];
    [format release];
    
    [request setParameters:params];
    //request type is post
    
    [request setHTTPMethod:@"GET"];
    
    //NSLog(@"%@",[[request URL] absoluteString]);
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];   
}
- (void)getUserCheckinHistoryForObjectId: (NSString *)objectId{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:GetGlueKey
                                                    secret:GetGlueSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://api.getglue.com/v2/user/checkins"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:2];
    if(objectId){
        OARequestParameter *object_Id = [[OARequestParameter alloc] initWithName:@"objectId" value:objectId];
        [params addObject:object_Id];
        [object_Id release];
    }
    
    
    OARequestParameter *format = [[OARequestParameter alloc] initWithName:@"format" value:@"json"];
    [params addObject:format];
    [format release];
    
    [request setParameters:params];
    //request type is post
    
    //NSLog(@"%@",params);
    [request setHTTPMethod:@"GET"];
    
    //NSLog(@"%@",[[request URL] absoluteString]);
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release]; 
}


/*User Methods */
- (void)addUserVisitToObjectId: (NSString *)objectId withSource: (NSString *)source fromApp:(NSString *)app{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:GetGlueKey
                                                    secret:GetGlueSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://api.getglue.com/v2/user/addVisit"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:5];
    OARequestParameter *object_Id = [[OARequestParameter alloc] initWithName:@"objectId" value:objectId];
    [params addObject:object_Id];
    [object_Id release];
    
    OARequestParameter *_source = [[OARequestParameter alloc] initWithName:@"source" value:source];
    [params addObject:_source];
    [_source release];
    
    OARequestParameter *_app = [[OARequestParameter alloc] initWithName:@"app" value:app];
    [params addObject:_app];
    [_app release];
    
    
    OARequestParameter *format = [[OARequestParameter alloc] initWithName:@"format" value:@"json"];
    [params addObject:format];
    [format release];
    
    [request setParameters:params];
    //request type is post
    
    [request setHTTPMethod:@"GET"];
    
    //NSLog(@"%@",[[request URL] absoluteString]);
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release]; 
}
- (void)addUserLikeToObjectId: (NSString *)objectId withSource: (NSString *)source fromApp: (NSString *)app withComment: (NSString *)comment{
    
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:objectId, @"objectId",
                               source, @"source",
                               app,@"app",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:comment, @"comment",
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/user/addLike"];
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams];
    
    
}
- (void)addUserDisLikeToObjectId: (NSString *)objectId withSource: (NSString *)source fromApp: (NSString *)app withComment: (NSString *)comment{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:objectId, @"objectId",
                               source, @"source",
                               app,@"app",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:comment, @"comment",
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/user/addDislike"];
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams];
}
- (void)addUserFavoriteToObjectId: (NSString *)objectId withSource: (NSString *)source fromApp: (NSString *)app withComment: (NSString *)comment{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:objectId, @"objectId",
                               source, @"source",
                               app,@"app",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:comment, @"comment",
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/user/addFavorite"];
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams];
}
- (void)addUserAskFriendsToObjectId: (NSString *)objectId withSource: (NSString *)source fromApp: (NSString *)app withComment: (NSString *)comment{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:objectId, @"objectId",
                               source, @"source",
                               app,@"app",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:comment, @"comment",
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/user/askFriends"];
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams]; 
}
- (void)removeUserInteractionForObjectId: (NSString *)objectId{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:objectId, @"objectId",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/user/removeInteraction"];
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams]; 
}
- (void)addUserReplyToObjectId: (NSString *)objectId fromApp: (NSString *)app inReplyToUserId: (NSString *)replyTo withComment: (NSString *)comment forCheckInTimeStamp: (NSString *)timestamp{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:objectId, @"objectId",
                               app, @"app",
                               replyTo,@"replyTo",
                               comment,@"comment",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:timestamp, @"timestamp",
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/user/addReply"];
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams]; 
    
}
- (void)removeUserReplyToObjectID: (NSString *)objectId inReplyToUserId: (NSString *)userId withTimeStamp: (NSString *)timestamp{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:objectId, @"objectId",
                               userId, @"userId",
                               timestamp,@"timestamp",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/user/removeReply"];
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams];
}
- (void)getUserProfileForUserId:(NSString *)userId andStickersForObjectId: (NSString *)stickerObjectId andStickersForPartner: (NSString *)stickerPartner{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:userId, @"userId",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:stickerObjectId,@"stickerObjectId",
                               stickerPartner,@"stickerPartner",
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/user/profile"];
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams];
}
- (void)getUserFriendsForUserId: (NSString *)userId{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:userId, @"userId",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/user/friends"];
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams];
}
- (void)getUserFollowersForUserId: (NSString *)userId{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:userId, @"userId",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/user/followers"];
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams];
}
- (void)isUserId: (NSString *)userId friendsWithUserId: (NSString *)friendUserId{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:userId, @"userId",
                               friendUserId,@"friendUserId",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/user/isFriend"];
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams];
}
- (void)followUserId: (NSString *)followUserId{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:followUserId, @"followUserId",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/user/follow"];
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams];
}
- (void)unFollowUserId: (NSString *)unfollowUserId{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:unfollowUserId, @"unfollowUserId",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/user/unfollow"]; 
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams];
}
- (void)getUserInteractionsForUserId: (NSString *)userId inCategory: (NSString *)category{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:userId, @"userId",
                               category,@"category",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/user/objects"]; 
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams];
}
- (void)getUserInteractionsForUserId: (NSString *)userId andObjectId: (NSString *)objectId{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:userId, @"userId",
                               objectId,@"objectId",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/user/object"]; 
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams]; 
}
- (void)getUserStreamOfType: (NSString *)streamType inCategory: (NSString *)category{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:streamType, @"streamType",
                               category,@"category",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/user/stream"]; 
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams];  
}
- (void)getListOfGuruItemsForUserId: (NSString *)userId{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:userId, @"userId",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/user/guru"]; 
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams];  
}
- (void)getUserStickersForUserId: (NSString *)userId{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:userId, @"userId",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/user/stickers"]; 
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams];
}

/*Object Methods  */

- (void)getObjectforId: (NSString *)objectId{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:objectId, @"objectId",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/object/get"]; 
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams]; 
}

- (void)getUserActivityForObjectId: (NSString *)objectId forAction: (NSString *)action andTotal:(NSString *)total andNumItems:(NSString *)numItems{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:objectId, @"objectId",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:action,@"action",
                               total,@"total",
                               numItems,@"numItems",
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/object/users"]; 
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams]; 
}
- (void)getLinksForObjectId: (NSString *)objectId{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:objectId, @"objectId",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/object/links"]; 
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams];  
}
- (void)getRepliesForObjectId: (NSString *)objectId forUserId:(NSString *)userID{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:objectId, @"objectId",
                               userID, @"userId",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/object/replies"]; 
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams]; 
}
- (void)getSimilarObjectsForObjectId: (NSString *)objectId{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:objectId, @"objectId",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/object/similar"]; 
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams]; 
}

/*Network Methods */

- (void)getCategories{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:@"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/glue/categories"]; 
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams]; 
}
- (void)getPopularItemsInCategory:(NSString *)category{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:category,@"category",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/glue/popular"]; 
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams];
}
- (void)getTopUsersInCategory:(NSString *)category{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:category,@"category",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/glue/topUsers"]; 
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams]; 
}
- (void)findObjectWithQuery:(NSString *)q{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:q,@"q",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/glue/findObjects"]; 
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams];
}
- (void)findUserWithQuery:(NSString *)userId{
    NSDictionary *reqparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:userId,@"userId",
                               @"json",@"format",
                               nil];
    
    NSDictionary *optparams = [[NSDictionary alloc] 
                               initWithObjectsAndKeys:
                               nil];
    NSString *apiurl = [NSString stringWithFormat:@"http://api.getglue.com/v2/glue/findUsers"]; 
    [self doApiCallForUrl:apiurl withRequiredParams:reqparams andOptionalParams:optparams]; 
}










/*************** utility functions ***********************/
- (void)apiTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    //NSLog(responseBody);
    NSDictionary *responsedata = [responseBody JSONValue];
    //NSLog(@"%@",responsedata);    
    [delegate finishedRetrievingApi:responsedata];
    [responseBody release];
    
}

- (void)apiTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    //NSLog(@"%@",[error description]);
    [delegate finishedRetrievingApiError:error];
}

- (NSDictionary *)parseQueryString:(NSString *)query {
    
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithCapacity:6] autorelease];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [dict setObject:val forKey:key];
    }
    return dict;
}



@end
