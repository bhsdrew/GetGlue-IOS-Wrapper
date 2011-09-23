//
//  GetGlue_WrapperAppDelegate.h test2
//  GetGlue Wrapper
//
//  Created by Andrew Fernandez on 6/9/11.
//  Copyright 2011 IronsoftStudios.com All rights reserved.
//

#import <UIKit/UIKit.h>

@class GetGlue_WrapperViewController;

@interface GetGlue_WrapperAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet GetGlue_WrapperViewController *viewController;

@end
