//
//  GetGlueDialog.m
//  GetGlue Wrapper
//
//  Created by Andrew Fernandez on 6/9/11.
//  Copyright 2011 IronsoftStudios.com All rights reserved.
//

#import "GetGlueDialog.h"

@implementation GetGlueDialog
@synthesize url;
@synthesize GetGlueconsumer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString *newurl = [[request URL] scheme];
    //NSLog(@"%@",newurl);
    //NSLog(@"%@",[[request URL] absoluteString]);
    if([newurl isEqualToString:@"GetGluewrap"]){
        //NSLog(@"paramstring: %@",[[request URL] query]);
        
        //[GetGlueconsumer setAuthorizeParams:[[request URL] query]];
        [GetGlueconsumer authorizeUser];
        [self.view removeFromSuperview];
        
    }
    return YES;
}

- (void)dismissGetGlueWebView{
    [self.view removeFromSuperview];
}

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

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

-(id) initWithUrl:(NSURL *)authurl GetGlueClass:(GetGlue *)GetGlueparent{
    self.GetGlueconsumer = GetGlueparent;
    UIWebView *authscreen = [[UIWebView alloc] initWithFrame:CGRectMake(0 , -20, 320, 480)];
    [authscreen loadRequest:[NSURLRequest requestWithURL:authurl]];
    [authscreen setDelegate:self];
    UIViewController *authview = [[UIViewController alloc] init];
    [authview.view addSubview:authscreen];
    
    UIButton *GetGlueclose = [UIButton buttonWithType:UIButtonTypeCustom];
    [GetGlueclose setBackgroundImage:[UIImage imageNamed:@"closebutton.png"] forState:UIControlStateNormal];
    
    //[GetGlueclose setBackgroundImage:[UIImage imageNamed:@"toolButtonselected.png"]forState:UIControlStateSelected];
    
    [GetGlueclose setTitle:@"" forState:UIControlStateNormal];
    [GetGlueclose addTarget:self action:@selector(dismissGetGlueWebView) forControlEvents:UIControlEventTouchUpInside];
    GetGlueclose.frame = CGRectMake(275, -15, 37, 38);
    [authview.view addSubview:GetGlueclose];
    [self.view addSubview:authview.view];
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    
    [window.rootViewController.view addSubview:self.view];
    [authview release];
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
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
