//
//  LWAppDelegate.m
//  topic
//
//  Created by Lukas K on 04.07.14.
//  Copyright (c) 2014 TEST. All rights reserved.
//

#import "LWAppDelegate.h"
#import "LWServerGateway.h"
#import "LWDatabaseGateway.h"
#import "LWFbUser.h"

@implementation LWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //NSLog(@"%@",[[NSBundle mainBundle] bundlePath]);
    [FBLoginView class];

    if ([[FBSession activeSession] state] == FBSessionStateCreatedTokenLoaded)
    {
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error)
                                                    {
                                                        // Handler for session state changes
                                                        // This method will be called EACH time the session state changes,
                                                        // also for intermediate states and NOT just when the session open
                                                        [self sessionStateChanged:session state:state error:error];
                                                    }];
    }

    return YES;
}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen)
    {
        
        NSLog(@"Session opened");
        
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
            if (error) {
                
                NSLog(@"error:%@",error);
            }
            else
            {
                // retrive user's details at here as shown below
                // Create or update facebook user
                [LWServerGateway instance].fbUser = [LWDatabaseGateway fbUserWithFacebookId:user.objectID firstName:[user first_name] lastName:[user last_name]];
                
                [[LWServerGateway instance] uploadFbUser:[LWServerGateway instance].fbUser];
                
                /*NSLog(@"FB user last name:%@",user.last_name);
                NSLog(@"FB user birthday:%@",user.birthday);
                NSLog(@"FB user location:%@",user.location);
                NSLog(@"FB user username:%@",user.username);
                NSLog(@"FB user gender:%@",[user objectForKey:@"gender"]);
                NSLog(@"email id:%@",[user objectForKey:@"email"]);
                NSLog(@"location:%@", [NSString stringWithFormat:@"Location: %@\n\n",
                                       user.location[@"name"]]);*/
                
            }
        }];
        
        // Show the user the logged-in UI
        [self userLoggedIn];
        
        [[LWServerGateway instance] setTokenAndStartSync:session.accessTokenData.accessToken];
        
        return;
    }
    
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed)
    {
        // If the session is closed
        NSLog(@"Session closed");
        
        // Show the user the logged-out UI
        [self userLoggedOut];
    }

    // Handle errors
    if (error)
    {
        NSLog(@"Error");
        
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error])
        {
            [self showMessage:[FBErrorUtility userMessageForError:error] withTitle:@"Something went wrong"];
        }
        else
        {
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled)
            {
                NSLog(@"User cancelled login");

                // Handle session closures that happen outside of the app
            }
            else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession)
            {
                [self showMessage:@"Your current session is no longer valid. Please log in again." withTitle:@"Session Error"];

                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            }
            else
            {
                //Get more error information from the error
                NSDictionary *errorInformation = [error userInfo][@"com.facebook.sdk:ParsedJSONResponseKey"][@"body"][@"error"];

                // Show the user an error message
                NSString *alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", errorInformation[@"message"]];
                [self showMessage:alertText withTitle:@"Something went wrong"];
            }
        }
        
        // Clear this token
        [[FBSession activeSession] closeAndClearTokenInformation];
        
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title message:text delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (void)userLoggedIn
{
    UINavigationController *rootNavigationController = (UINavigationController *)[[self window] rootViewController];

    if ([[rootNavigationController viewControllers] count] == 1)
    {
        UIViewController *topicListController = [[rootNavigationController storyboard] instantiateViewControllerWithIdentifier:@"TopicList"];
        [rootNavigationController setViewControllers:@[topicListController] animated:YES];
    }
}

- (void)userLoggedOut
{
    UINavigationController *rootNavigationController = (UINavigationController *)[[self window] rootViewController];
    UIViewController *topicListController = [[rootNavigationController storyboard] instantiateViewControllerWithIdentifier:@"Login"];
    [rootNavigationController setViewControllers:@[topicListController] animated:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    [FBAppCall handleDidBecomeActive];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    // Note this handler block should be the exact same as the handler passed to any open calls.
    [[FBSession activeSession] setStateChangeHandler:^(FBSession *session, FBSessionState state, NSError *error)
    {
        // Retrieve the app delegate
        LWAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
        [appDelegate sessionStateChanged:session state:state error:error];
    }];
    
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

@end
