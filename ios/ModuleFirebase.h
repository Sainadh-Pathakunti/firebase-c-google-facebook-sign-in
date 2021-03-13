
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <GoogleSignIn/GIDAuthentication.h>
#import <GoogleSignIn/GIDSignIn.h>
#import <Firebase/Firebase.h>
#import "RootViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <AuthenticationServices/AuthenticationServices.h>


@interface ModuleFirebase :  NSObject<GIDSignInDelegate,ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding>{
    
    FBSDKLoginManager* loginManager;
    GIDSignIn *googleSignIn;
    UIViewController* controller;
    
}

@property(strong) NSString *currentNonce;

- (void) initialize;
- (void) generateToken:(NSObject*) params;
- (void) signIn:(NSObject *)params;

//AppDelegate functions
+ (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
+ (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
+ (void) applicationDidBecomeActive:(UIApplication *)application;
+ (void) postCustomEvent:(NSObject*) params;


@end
