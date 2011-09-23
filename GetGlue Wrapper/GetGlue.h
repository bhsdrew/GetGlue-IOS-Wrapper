//
//  GetGlue.h
//  GetGlue Wrapper
//
//  Created by Andrew Fernandez on 6/9/11.
//  Copyright 2011 IronsoftStudios.com All rights reserved.
/*
 Copyright (c) 2011 Andrew Fernandez
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
 
 */


#import <Foundation/Foundation.h>
#import "OAuthConsumer.h"

#define GetGlueRequestTokenUrl     @"http://api.getglue.com/oauth/request_token"
#define GetGlueAuthorizeUrl        @"http://getglue.com/oauth/authorize"
#define GetGlueAccessTokenUrl      @"http://api.getglue.com/oauth/access_token"
@protocol GetGlueDelegate;


@interface GetGlue : NSObject  <UIWebViewDelegate>{
    id<GetGlueDelegate> delegate;
    OAToken *requestToken;
    NSString *authorizeParams;
    OAToken *accessToken;
    NSString *loggedinuser;
}

@property (nonatomic,retain) OAToken *requestToken;
@property (nonatomic,retain) NSString *authorizeParams;
@property (nonatomic,retain) OAToken *accessToken;
@property (nonatomic,assign) id<GetGlueDelegate> delegate;
@property (nonatomic,retain) NSString *loggedinuser;


- (void) initiateGetGlue;
- (void) authorizeUser;
- (void) logout;

- (NSDictionary *)parseQueryString:(NSString *)query;
- (void)doApiCallForUrl: (NSString *)url withRequiredParams:(NSDictionary *)reqparams andOptionalParams:(NSDictionary *)optparams;

/*Check-in Methods */

- (void)userAddCheckInForObjectId: (NSString *)objectId withSource:(NSString *)source fromApp:(NSString *)app andComment:(NSString *)comment;
- (void)userRemoveCheckInForObjectId: (NSString *)objectId atTimeStamp:(NSString *)timestamp;
- (void)getAllUserCheckInsForObjectId: (NSString *)objectId; //param action=checkedIn
- (void)getLastUserCheckInForObjectId: (NSString *)objectId; //param action=lastCheckedIn
- (void)getUserCheckinHistoryForObjectId: (NSString *)objectId;


/*User Methods */
- (void)addUserVisitToObjectId: (NSString *)objectId withSource: (NSString *)source fromApp:(NSString *)app;
- (void)addUserLikeToObjectId: (NSString *)objectId withSource: (NSString *)source fromApp: (NSString *)app withComment: (NSString *)comment;
- (void)addUserDisLikeToObjectId: (NSString *)objectId withSource: (NSString *)source fromApp: (NSString *)app withComment: (NSString *)comment;
- (void)addUserFavoriteToObjectId: (NSString *)objectId withSource: (NSString *)source fromApp: (NSString *)app withComment: (NSString *)comment;
- (void)addUserAskFriendsToObjectId: (NSString *)objectId withSource: (NSString *)source fromApp: (NSString *)app withComment: (NSString *)comment;
- (void)removeUserInteractionForObjectId: (NSString *)objectId;
- (void)addUserReplyToObjectId: (NSString *)objectId fromApp: (NSString *)app inReplyToUserId: (NSString *)replyTo withComment: (NSString *)comment forCheckInTimeStamp: (NSString *)timestamp;
- (void)removeUserReplyToObjectID: (NSString *)objectId inReplyToUserId: (NSString *)userId withTimeStamp: (NSString *)timestamp;
- (void)getUserProfileForUserId:(NSString *)userId andStickersForObjectId: (NSString *)stickerObjectId andStickersForPartner: (NSString *)stickerPartner;
- (void)getUserFriendsForUserId: (NSString *)userId;
- (void)getUserFollowersForUserId: (NSString *)userId;
- (void)isUserId: (NSString *)userId friendsWithUserId: (NSString *)friendUserId;
- (void)followUserId: (NSString *)followUserId;
- (void)unFollowUserId: (NSString *)unfollowUserId;
- (void)getUserInteractionsForUserId: (NSString *)userId inCategory: (NSString *)category;
- (void)getUserInteractionsForUserId: (NSString *)userId andObjectId: (NSString *)objectId;
- (void)getUserStreamOfType: (NSString *)streamType inCategory: (NSString *)category;
- (void)getListOfGuruItemsForUserId: (NSString *)userId;
- (void)getUserStickersForUserId: (NSString *)userId;

/*Object Methods  */

- (void)getObjectforId: (NSString *)objectId;

- (void)getUserActivityForObjectId: (NSString *)objectId forAction: (NSString *)action andTotal:(NSString *)total andNumItems:(NSString *)numItems;
- (void)getLinksForObjectId: (NSString *)objectId;
- (void)getRepliesForObjectId: (NSString *)objectId forUserId:(NSString *)userID;
- (void)getSimilarObjectsForObjectId: (NSString *)objectId;

/*Network Methods */

- (void)getCategories;
- (void)getPopularItemsInCategory:(NSString *)category;
- (void)getTopUsersInCategory:(NSString *)category;
- (void)findObjectWithQuery:(NSString *)q;
- (void)findUserWithQuery:(NSString *)userId;

@end

/*
 *Your application should implement this delegate
 */
@protocol GetGlueDelegate <NSObject>

@optional

-(void)finishedRetrievingApi:(NSDictionary *)data;
-(void)finishedRetrievingApiError:(NSError *)error;
-(void)finishedAuthorizingUser;

@end
