//
//  GetGlue_WrapperViewController.h
//  GetGlue Wrapper
//
//  Created by Andrew Fernandez on 6/9/11.
//  Copyright 2011 IronsoftStudios.com All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetGlue.h"

@interface GetGlue_WrapperViewController : UIViewController <GetGlueDelegate>{
    GetGlue *GetGluetest;
}

@property (nonatomic,retain) GetGlue *GetGluetest;
@end
