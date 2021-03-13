#import "ModuleFirebase.h"
#import "IOSNDKHelper.h"
#import <CommonCrypto/CommonCrypto.h>
#import <AuthenticationServices/AuthenticationServices.h>

@implementation ModuleFirebase

#pragma mark HELPERS
-(void) initialize
{
    [IOSNDKHelper addNDKReceiver:self moduleName:@"ndk-receiver-FireBaseHandler-module"];
    [FIRApp configure];
    
    loginManager = [[FBSDKLoginManager alloc] init];
    googleSignIn = [GIDSignIn sharedInstance];
    
    googleSignIn.clientID = @"******-c8v5i90m7qe75tonoarioo7vrnmg549s.apps.googleusercontent.com";
    googleSignIn.delegate = self;
    
    controller = [[[UIApplication sharedApplication] keyWindow] rootViewController];
}


/*****************************
 *          FACEBOOK         *
 *****************************/

- (BOOL)facebookIsSetup
{
    NSString *facebookAppId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"];
    NSString *facebookDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookDisplayName"];
    BOOL canOpenFacebook =[[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"fb://%@", facebookAppId]]];
  
    if ([@"<YOUR FACEBOOK APP ID>" isEqualToString:facebookAppId] ||
        [@"<YOUR FACEBOOK APP DISPLAY NAME>" isEqualToString:facebookDisplayName] || !canOpenFacebook) {
        [self showErrorAlertWithMessage:@"Please set FacebookAppID, FacebookDisplayName, and\nURL types > Url Schemes in `Supporting Files/Info.plist`"];
        return NO;
    } else {
        return YES;
    }
}

- (void)facebookButtonPressed
{
    if ([self facebookIsSetup]) {
        [self facebookLogin];
    }
}



- (void)facebookLogin{
    
//   if we want frnds and email use below array
//    [@(declare_str("public_profile")),@(declare_str("email")),@(declare_str("user_friends"))]
    [self loginWithReadPermissions:@[@"email"]];
    
}
-(void) loginWithReadPermissions:(NSArray*)permissions
{

   
    [loginManager logInWithPermissions:permissions fromViewController:controller
                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
     {
         if (error)
         {
//             CS_NSLOG(@"FACEBOOK: login ERROR");
             NSMutableDictionary *loginData = [self dumpError:error];
//             [IOSNDKHelper sendMessage:@(declare_str("onLoginResult")) withParameters:loginData];
         }
         else if (result.isCancelled)
         {
//             CS_NSLOG(@"FACEBOOK: login CANCELLED");
             NSMutableDictionary *loginData = [[NSMutableDictionary alloc] init];
//             [loginData setObject:@(declare_str("Cancelled by user")) forKey:@(declare_str("error"))];
//             [loginData setObject:[[NSNumber alloc] initWithInt:0] forKey:@(declare_str("code"))];
//             [IOSNDKHelper sendMessage:@(declare_str("onLoginResult")) withParameters:loginData];
         }
         else
         {
//             CS_NSLOG(@"FACEBOOK: login SUCCESS. Requesting USERDATA...");
             [self requestUserData:^(NSError* error) {
//                 [FBSDKAccessToken setCurrentAccessToken:nil]; //discard access token
//                 NSMutableDictionary *loginData = [self dumpError:error];
//                 [IOSNDKHelper sendMessage:@(declare_str("onLoginResult")) withParameters:loginData];
             }];
         }
     }];
}




/*****************************
 *          GOOGLE           *
 *****************************/




- (BOOL)application:(nonnull UIApplication *)application
            openURL:(nonnull NSURL *)url
            options:(nonnull NSDictionary<NSString *, id> *)options {
  return [googleSignIn handleURL:url];
}



- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
  // ...
  if (error == nil) {
    GIDAuthentication *authentication = user.authentication;
    FIRAuthCredential *credential =
    [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                     accessToken:authentication.accessToken];
    // ...
  } else {
      NSLog(@"Error: %@ %@", error, [error localizedDescription]);
//      NSLog("%d",[error localizedDescription])

  }
}

- (BOOL)googleIsSetup
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info" ofType:@"plist"];
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString *reversedClientId =[plist objectForKey:@"REVERSED_CLIENT_ID"];
    BOOL clientIdExists = [plist objectForKey:@"CLIENT_ID"] != nil;
    BOOL reversedClientIdExists = reversedClientId != nil;
    BOOL canOpenGoogle =[[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", reversedClientId]]];

    if (!(clientIdExists && reversedClientIdExists && canOpenGoogle)) {
        [self showErrorAlertWithMessage:@"Please add `GoogleService-Info.plist` to `Supporting Files` and\nURL types > Url Schemes in `Supporting Files/Info.plist`"];
        return NO;
    } else {
        return YES;
    }
}

- (void)googleLogin
{
    googleSignIn.presentingViewController = controller;
    [googleSignIn signIn];
}



/*****************************
 *         Apple SignIn         *
 *****************************/


- (void)startSignInWithAppleFlow {
    
  UIViewController* controller = [[[UIApplication sharedApplication] keyWindow] rootViewController];
  
    NSString *nonce = [self randomNonce:32];
  self.currentNonce = nonce;
  ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
  ASAuthorizationAppleIDRequest *request = [appleIDProvider createRequest];
  request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
  request.nonce = [self stringBySha256HashingString:nonce];

  ASAuthorizationController *authorizationController =
  [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
  
  authorizationController.delegate = self;
  authorizationController.presentationContextProvider = self;
  [authorizationController performRequests];
}

- (NSString *)stringBySha256HashingString:(NSString *)input {
  const char *string = [input UTF8String];
  unsigned char result[CC_SHA256_DIGEST_LENGTH];
  CC_SHA256(string, (CC_LONG)strlen(string), result);

  NSMutableString *hashed = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
  for (NSInteger i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
    [hashed appendFormat:@"%02x", result[i]];
  }
  return hashed;
}


- (NSString *)randomNonce:(NSInteger)length {
  NSAssert(length > 0, @"Expected nonce to have positive length");
  NSString *characterSet = @"0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._";
  NSMutableString *result = [NSMutableString string];
  NSInteger remainingLength = length;

  while (remainingLength > 0) {
    NSMutableArray *randoms = [NSMutableArray arrayWithCapacity:16];
    for (NSInteger i = 0; i < 16; i++) {
      uint8_t random = 0;
      int errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random);
      NSAssert(errorCode == errSecSuccess, @"Unable to generate nonce: OSStatus %i", errorCode);

      [randoms addObject:@(random)];
    }

    for (NSNumber *random in randoms) {
      if (remainingLength == 0) {
        break;
      }

      if (random.unsignedIntValue < characterSet.length) {
        unichar character = [characterSet characterAtIndex:random.unsignedIntValue];
        [result appendFormat:@"%C", character];
        remainingLength--;
      }
    }
  }

  return result;
}



/*****************************
 *          TWITTER          *
 *****************************/

- (void)twitterButtonPressed
{
    if ([self twitterIsSetup]) {
        [self twitterLogin];
    }
}

- (void)showErrorAlertWithMessage:(NSString *)message
{
    // display an alert with the error message
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)twitterLogin
{
//    self.twitterAuthHelper = [[TwitterAuthHelper alloc] initWithFirebaseRef:self.ref apiKey:kTwitterAPIKey];
//    [self.twitterAuthHelper selectTwitterAccountWithCallback:^(NSError *error, NSArray *accounts) {
//        if (error) {
//            NSString *message = [NSString stringWithFormat:@"There was an error logging into Twitter: %@", [error localizedDescription]];
//            [self showErrorAlertWithMessage:message];
//        } else {
//            // here you could display a dialog letting the user choose
//            // for simplicity we just choose the first
//            [self showProgressAlert];
//            [self.twitterAuthHelper authenticateAccount:[accounts firstObject]
//                                           withCallback:[self loginBlockForProviderName:@"Twitter"]];
//
//            // If you wanted something more complicated, comment the above line out, and use the below line instead.
//            // [self twitterHandleAccounts:accounts];
//        }
//    }];
}

/*****************************
 *      ADV TWITTER STUFF    *
 *****************************/
- (void)twitterHandleAccounts:(NSArray *)accounts
{
//    // Handle the case based on how many twitter accounts are registered with the phone.
//    switch ([accounts count]) {
//        case 0:
//            // There is currently no Twitter account on the device.
//            break;
//        case 1:
//            // Single user system, go straight to login
//            [self.twitterAuthHelper authenticateAccount:[accounts firstObject]
//                                           withCallback:[self loginBlockForProviderName:@"Twitter"]];
//            break;
//        default:
//            // Handle multiple users by showing action sheet
//            [self twitterShowAccountsSheet:accounts];
//            break;
//    }
}

// For this, you'll need to make sure that your ViewController is a UIActionSheetDelegate.
- (void)twitterShowAccountsSheet:(NSArray *)accounts
{
//    UIActionSheet *selectUserActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Twitter Account" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
//    for (ACAccount *account in accounts) {
//        [selectUserActionSheet addButtonWithTitle:[account username]];
//    }
//    selectUserActionSheet.cancelButtonIndex = [selectUserActionSheet addButtonWithTitle:@"Cancel"];
//    [selectUserActionSheet showInView:self.view];
}

// Delegate to handle Twitter action sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    NSString *currentTwitterHandle = [actionSheet buttonTitleAtIndex:buttonIndex];
//
//    for (ACAccount *account in self.twitterAuthHelper.accounts) {
//        if ([currentTwitterHandle isEqualToString:account.username]) {
//            [self.twitterAuthHelper authenticateAccount:account
//                                           withCallback:[self loginBlockForProviderName:@"Twitter"]];
//        }
//    }
}

- (BOOL)twitterIsSetup
{
//    if ([@"<your-twitter-app-id>" isEqualToString:kTwitterAPIKey]) {
//        [self showErrorAlertWithMessage:@"Please set kTwitterAPIKey to your Twitter API Key in ViewController.m"];
//        return NO;
//    } else {
//        return YES;
//    }
}

-(void) generateToken:(NSObject*) params
{
   
    [self startSignInWithAppleFlow];
    
    
//
//    [GIDSignIn sharedInstance].presentingViewController = self;
//    [[GIDSignIn sharedInstance] signIn];
    
//    [FIRApp configure];

//    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
//    [GIDSignIn sharedInstance].delegate = self;
    
//    NSDictionary *parameters = (NSDictionary*)params;
//    NSString *schema = [parameters valueForKey:@"packageName"];
//
////    NSURL *url = [NSURL URLWithString:schema];
////    BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:url];
//
//    BOOL isInstalled = [self isInstalled:schema];
//
//    NSMutableDictionary *array = [[NSMutableDictionary alloc] init];
//    [array setObject:[NSNumber numberWithBool:isInstalled] forKey:[NSString stringWithFormat:@"isInstalled"]];
//    [array setObject:schema forKey:[NSString stringWithFormat:@"packageName"]];
//
//
//    [IOSNDKHelper sendMessage:@"setTokenData" withParameters:array];
}






#pragma mark APPLICATION delegate overrides

+(BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

+(BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return[[FBSDKApplicationDelegate sharedInstance] application:application openURL:url
                                                    sourceApplication:sourceApplication
                                                    annotation:annotation];
}

+(void) applicationDidBecomeActive:(UIApplication *)application
{
    [FBSDKAppEvents activateApp];
}


+(void) postCustomEvent:(NSObject*)params
{

}

@end
