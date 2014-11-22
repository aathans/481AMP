//
//  ADAppDelegate.m
//  FirmataTestMac
//
//  Created by fiore on 31/10/13.
//  Copyright (c) 2013 Fiore Basile. All rights reserved.
//

#import "AMPAppDelegate.h"
#import "ORSSerialPortManager.h"
#import "ORSSerialPort.h"
#import "ADArduino.h"
#import "ADUnixSerialPort.h"
#import "PHLoadingViewController.h"
#import "AMPControlLightsViewController.h"

@interface AMPAppDelegate()

@property (nonatomic, strong) NSAlert *noConnectionAlert;
@property (nonatomic, strong) NSAlert *noBridgeFoundAlert;
@property (nonatomic, strong) NSAlert *authenticationFailedAlert;

@property (nonatomic, strong) NSPanel *currentSheetWindow;

@property (nonatomic, strong) PHBridgeSelectionViewController *bridgeSelectionViewController;
@property (nonatomic, strong) PHLoadingViewController *loadingViewController;
@property (nonatomic, strong) PHBridgePushLinkViewController *pushLinkViewController;
@property (nonatomic, strong) AMPControlLightsViewController *controlLightsViewController;
@property (nonatomic, strong) PHBridgeSearching *bridgeSearch;

@end

@implementation AMPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.controlLightsViewController = [[AMPControlLightsViewController alloc] initWithNibName:@"AMPControlLightsViewController" bundle:[NSBundle mainBundle]];
    
    self.controlLightsViewController.view.frame = ((NSView *)self.hueController.window.contentView).bounds;
    self.hueController.window.contentView = self.controlLightsViewController.view;
    [self.hueController showWindow:self];
    
    self.phHueSDK = [PHHueSDK new];
    [self.phHueSDK startUpSDK];
    [self.phHueSDK enableLogging:YES];
    
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    
    [notificationManager registerObject:self withSelector:@selector(localConnection) forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(notAuthenticated) forNotification:NO_LOCAL_AUTHENTICATION_NOTIFICATION];
    
    [self enableLocalHeartbeat];
    
    [self setupSerialPortGUI];
    
}

- (void) setupSerialPortGUI {
    
    self.rxLabel.stringValue = @"0";
    self.txLabel.stringValue = @"0";
    
    NSArray* availablePorts = [[ORSSerialPortManager sharedSerialPortManager] availablePorts ];
    for (ORSSerialPort* port in availablePorts) {
        [self.serialPortsCombo addItemWithObjectValue:port.path];
    }
    [self.serialPortsCombo selectItemAtIndex:0];
    
    NSArray* baudRates = [NSArray arrayWithObjects:@"19200", @"38400", @"57600",@"115200",nil];
    [self.serialBaudCombo addItemsWithObjectValues:baudRates];
    [self.serialBaudCombo selectItemAtIndex:2];

}


- (IBAction)connectAction:(id)sender {
    
    if (!self.connected) {
        self.rxLabel.stringValue = @"0";
        self.txLabel.stringValue = @"0";
        
        NSString* path = (NSString*)[self.serialPortsCombo objectValueOfSelectedItem];
        long baud = [(NSString*)[self.serialBaudCombo objectValueOfSelectedItem] integerValue];
        
        ADUnixSerialPort* port = [[ADUnixSerialPort alloc] initWithDevice:path baudRate:(int)baud timeout:3];
        
        [port addObserver:self forKeyPath:@"rxCount" options:NSKeyValueObservingOptionNew context:nil];
        [port addObserver:self forKeyPath:@"txCount" options:NSKeyValueObservingOptionNew context:nil];
    
        ADArduino* arduino = [[ADArduino alloc] initWithSerial:port];
        
        [self.detailController setArduino:arduino];
        [self.detailController showWindow:self];
        [self.connectButton setTitle:@"Disconnect"];
        
        self.connected = YES;
    } else {
        ADUnixSerialPort* port = (ADUnixSerialPort*) self.detailController.arduino.serialPort;
        
        [port removeObserver:self forKeyPath:@"rxCount"];
        [port removeObserver:self forKeyPath:@"txCount"];
        
        [self.detailController.window performClose:self];
        [self.detailController close];
        [self.detailController.arduino stopListening];
        [self.connectButton setTitle:@"Connect"];
        
        self.connected = NO;
    }
    
    
}

//***** PHILIPS HUE *******
- (void)applicationDidEnterBackground:(NSApplication *)application {
    [self disableLocalHeartbeat];
    
    [self hideCurrentSheetWindow];
    
    if (self.noConnectionAlert != nil) {
        self.noConnectionAlert = nil;
    }
    if (self.noBridgeFoundAlert != nil) {
        self.noBridgeFoundAlert = nil;
    }
    if (self.authenticationFailedAlert != nil) {
        self.authenticationFailedAlert = nil;
    }
}

- (void)applicationWillEnterForeground:(NSApplication *)application {
    [self enableLocalHeartbeat];
}

#pragma mark - HueSDK

/**
 Notification receiver for successful local connection
 */
- (void)localConnection {
    // Check current connection state
    [self checkConnectionState];
}

/**
 Notification receiver for failed local connection
 */
- (void)noLocalConnection {
    // Check current connection state
    [self checkConnectionState];
}

/**
 Notification receiver for failed local authentication
 */
- (void)notAuthenticated {
    /***************************************************
     We are not authenticated so we start the authentication process
     *****************************************************/
    
    /***************************************************
     doAuthentication will start the push linking
     *****************************************************/
    
    // Start local authenticion process
    [self performSelector:@selector(doAuthentication) withObject:nil afterDelay:0.5];
}

/**
 Checks if we are currently connected to the bridge locally and if not, it will show an error when the error is not already shown.
 */
- (void)checkConnectionState {
    if (!self.phHueSDK.localConnected) {
        if (self.noConnectionAlert == nil) {
            // Show popup
            [self showNoConnectionDialog];
        }
    }
    else {
        // One of the connections is made, remove popups and loading views
        [self hideCurrentSheetWindow];
    }
}

/**
 Shows the first no connection alert
 */
- (void)showNoConnectionDialog {
    [self hideCurrentSheetWindow];
    int response;
    self.noConnectionAlert=[[NSAlert alloc] init];
    [self.noConnectionAlert setMessageText:NSLocalizedString(@"No connection", @"No connection alert title")];
    [self.noConnectionAlert setInformativeText:NSLocalizedString(@"Connection to bridge is lost", @"No Connection alert message")];
    [self.noConnectionAlert addButtonWithTitle:NSLocalizedString(@"Reconnect", @"No connection alert reconnect button")];
    [self.noConnectionAlert addButtonWithTitle:NSLocalizedString(@"Find new bridge", @"No connection find new bridge button")];
    [self.noConnectionAlert addButtonWithTitle:NSLocalizedString(@"Cancel", @"No connection cancel noConnectionAlert")];
    [self.noConnectionAlert setAlertStyle:NSCriticalAlertStyle];
    
    [self.noConnectionAlert beginSheetModalForWindow:self.window
                                       modalDelegate:self
                                      didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                                         contextInfo:&response];
}

/**
 Shows the no bridges found alert
 */
- (void)showNoBridgesFoundDialog {
    [self hideCurrentSheetWindow];
    int response;
    self.noBridgeFoundAlert=[[NSAlert alloc] init];
    [self.noBridgeFoundAlert setMessageText:NSLocalizedString(@"No bridges", @"No bridge found alert title")];
    [self.noBridgeFoundAlert setInformativeText:NSLocalizedString(@"Could not find bridge", @"No bridge found alert message")];
    [self.noBridgeFoundAlert addButtonWithTitle:NSLocalizedString(@"Retry", @"No bridge found alert retry button")];
    [self.noBridgeFoundAlert addButtonWithTitle:NSLocalizedString(@"Cancel", @"No bridge found alert cancel button")];
    [self.noBridgeFoundAlert setAlertStyle:NSCriticalAlertStyle];
    
    [self.noBridgeFoundAlert beginSheetModalForWindow:self.window
                                        modalDelegate:self
                                       didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                                          contextInfo:&response];
}

/**
 Shows the not authenticated alert
 */
- (void)showNotAuthenticatedDialog{
    [self hideCurrentSheetWindow];
    int response;
    self.authenticationFailedAlert=[[NSAlert alloc] init];
    [self.authenticationFailedAlert setMessageText:NSLocalizedString(@"Authentication failed", @"Authentication failed alert title")];
    [self.authenticationFailedAlert setInformativeText:NSLocalizedString(@"Make sure you press the button within 30 seconds", @"Authentication failed alert message")];
    [self.authenticationFailedAlert addButtonWithTitle:NSLocalizedString(@"Retry", @"Authentication failed alert retry button")];
    [self.authenticationFailedAlert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Authentication failed cancel button")];
    [self.authenticationFailedAlert setAlertStyle:NSCriticalAlertStyle];
    
    [self.authenticationFailedAlert beginSheetModalForWindow:self.window
                                               modalDelegate:self
                                              didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                                                 contextInfo:&response];
}

#pragma mark - Heartbeat control

/**
 Starts the local heartbeat with a 10 second interval
 */
- (void)enableLocalHeartbeat {
    /***************************************************
     The heartbeat processing collects data from the bridge
     so now try to see if we have a bridge already connected
     *****************************************************/
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil) {
        // Hide sheet if there is any
        [self hideCurrentSheetWindow];
        
        // Show a connecting sheet while we try to connect to the bridge
        [self showLoadingViewWithText:NSLocalizedString(@"Connecting...", @"Connecting text")];
        
        // Enable heartbeat with interval of 10 seconds
        [self.phHueSDK enableLocalConnection];
    } else {
        // Automaticly start searching for bridges
        [self searchForBridgeLocal];
    }
}

/**
 Stops the local heartbeat
 */
- (void)disableLocalHeartbeat {
    [self.phHueSDK disableLocalConnection];
}

#pragma mark - Bridge searching and selection

/**
 Search for bridges using UPnP and portal discovery, shows results to user or gives error when none found.
 */
- (void)searchForBridgeLocal {
    // Stop heartbeats
    [self disableLocalHeartbeat];
    
    // Remove currently showing popups, loading sheets or other screens
    [self hideCurrentSheetWindow];
    
    // Show search screen
    [self showLoadingViewWithText:NSLocalizedString(@"Searching for bridges...", @"Searching for bridges text")];
    /***************************************************
     A bridge search is started using UPnP to find local bridges
     *****************************************************/
    
    // Start search
    self.bridgeSearch = [[PHBridgeSearching alloc] initWithUpnpSearch:YES andPortalSearch:YES andIpAdressSearch:YES];
    [self.bridgeSearch startSearchWithCompletionHandler:^(NSDictionary *bridgesFound) {
        
        // Done with search, remove loading sheet view
        [self hideCurrentSheetWindow];
        
        /***************************************************
         The search is complete, check whether we found a bridge
         *****************************************************/
        
        // Check for results
        if (bridgesFound.count > 0) {
            // Results were found, show options to user (from a user point of view, you should select automatically when there is only one bridge found)
            
            /***************************************************
             Use the list of bridges, present them to the user, so one can be selected.
             *****************************************************/
            self.bridgeSelectionViewController = [[PHBridgeSelectionViewController alloc] initWithNibName:@"PHBridgeSelectionViewController" bundle:[NSBundle mainBundle] bridges:bridgesFound delegate:self];
            
            [self showSheetController:self.bridgeSelectionViewController];
            
        }
        else {
            /***************************************************
             No bridge was found was found. Tell the user and offer to retry..
             *****************************************************/
            
            // No bridges were found, show this to the user
            [self showNoBridgesFoundDialog];
        }
    }];
    
}

/**
 Delegate method for PHbridgeSelectionViewController which is invoked when a bridge is selected
 */
- (void)bridgeSelectedWithIpAddress:(NSString *)ipAddress andMacAddress:(NSString *)macAddress {
    /***************************************************
     Removing the selection view controller takes us to
     the 'normal' UI view
     *****************************************************/
    [self hideCurrentSheetWindow];
    
    // Show a connecting loading sheet while we try to connect to the bridge
    [self showLoadingViewWithText:NSLocalizedString(@"Connecting...", @"Connecting text")];
    
    // Set SDK to use bridge and our default username (which should be the same across all apps, so pushlinking is only required once)
    
    /***************************************************
     Set the username, ipaddress and mac address,
     as the bridge properties that the SDK framework will use
     *****************************************************/
    
    [NSAppDelegate.phHueSDK setBridgeToUseWithIpAddress:ipAddress macAddress:macAddress];
    
    /***************************************************
     Setting the hearbeat running will cause the SDK
     to regularly update the cache with the status of the
     bridge resources
     *****************************************************/
    
    // Start local heartbeat again
    [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
}

#pragma mark - Bridge authentication

/**
 Start the local authentication process
 */
- (void)doAuthentication {
    // Disable heartbeats
    [self disableLocalHeartbeat];
    
    // Remove loading sheet view
    [self hideCurrentSheetWindow];
    
    /***************************************************
     To be certain that we own this bridge we must manually
     push link it. Here we display the view to do this.
     *****************************************************/
    
    // Create an interface for the pushlinking
    self.pushLinkViewController = [[PHBridgePushLinkViewController alloc] initWithNibName:@"PHBridgePushLinkViewController" bundle:[NSBundle mainBundle] delegate:self];
    
    [self showSheetController:self.pushLinkViewController];
    
    /***************************************************
     Start the push linking process.
     *****************************************************/
    
    // Start pushlinking when the interface is shown
    [self.pushLinkViewController startPushLinking];
}

/**
 Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was successfull
 */
- (void)pushlinkSuccess {
    /***************************************************
     Push linking succeeded we are authenticated against
     the chosen bridge.
     *****************************************************/
    
    // Remove pushlink view controller
    [self hideCurrentSheetWindow];
    
    // Start local heartbeat
    [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
}

/**
 Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was not successfull
 */
- (void)pushlinkFailed:(PHError *)error {
    // Remove pushlink view controller
    [self hideCurrentSheetWindow];
    
    // Check which error occured
    if (error.code == PUSHLINK_NO_CONNECTION) {
        // No local connection to bridge
        [self noLocalConnection];
        
        // Start local heartbeat (to see when connection comes back)
        [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
    }
    else {
        // Bridge button not pressed in time
        [self showNotAuthenticatedDialog];
    }
}

#pragma mark - Alertview delegate

- (void)alertDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    
    [[(NSAlert*)sheet window] orderOut:self];
    
    if (sheet == (NSWindow*)self.noConnectionAlert) {
        // This is a no connection alert with option to reconnect or more options
        self.noConnectionAlert = nil;
        
        if (returnCode == NSAlertFirstButtonReturn) {
            // Retry, just wait for the heartbeat to finish
            [self showLoadingViewWithText:NSLocalizedString(@"Connecting...", @"Connecting text")];
        }
        else if (returnCode == NSAlertSecondButtonReturn) {
            // Find new bridge button
            [self searchForBridgeLocal];
        }
        else if (returnCode == NSAlertThirdButtonReturn) {
            // Cancel and disable local heartbeat unit started manually again
            [self disableLocalHeartbeat];
        }
    }
    else if (sheet == (NSWindow*)self.noBridgeFoundAlert) {
        // This is the alert which is shown when no bridges are found locally
        self.noBridgeFoundAlert = nil;
        
        if (returnCode == NSAlertFirstButtonReturn) {
            // Retry
            [self searchForBridgeLocal];
        } else if (returnCode == NSAlertSecondButtonReturn) {
            // Cancel and disable local heartbeat unit started manually again
            [self disableLocalHeartbeat];
        }
    }
    else if (sheet == (NSWindow*)self.authenticationFailedAlert) {
        // This is the alert which is shown when local pushlinking authentication has failed
        self.authenticationFailedAlert = nil;
        
        if (returnCode == NSAlertFirstButtonReturn) {
            // Retry authentication
            [self doAuthentication];
        } else if (returnCode == NSAlertSecondButtonReturn) {
            // Cancel authentication and disable local heartbeat unit started manually again
            [self disableLocalHeartbeat];
        }
    }
    
}

#pragma mark - Sheet management

- (void)showSheetController:(NSViewController*)sheetController{
    NSRect frame = sheetController.view.bounds;
    self.currentSheetWindow  = [[NSPanel alloc] initWithContentRect:frame
                                                          styleMask: NSTitledWindowMask | NSClosableWindowMask
                                                            backing:NSBackingStoreBuffered
                                                              defer:NO];
    [self.currentSheetWindow.contentView addSubview:sheetController.view];
    
    [[NSApplication sharedApplication] beginSheet:self.currentSheetWindow
                                   modalForWindow:self.window
                                    modalDelegate:self
                                   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
                                      contextInfo:nil];
}

- (void)showLoadingViewWithText:(NSString*)message{
    if (self.loadingViewController == nil) {
        self.loadingViewController = [[PHLoadingViewController alloc] initWithNibName:@"PHLoadingViewController" bundle:[NSBundle mainBundle]];
    }
    [self showSheetController:self.loadingViewController];
    [self.loadingViewController setLoadingWithMessage:message];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    [sheet orderOut:self];
    self.currentSheetWindow = nil;
}

- (void)hideCurrentSheetWindow{
    if (self.currentSheetWindow!=nil){
        [[NSApplication sharedApplication] endSheet:self.currentSheetWindow returnCode: NSCancelButton];
    }
}

//*********************

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"rxCount"]) {
         self.rxLabel.stringValue = [NSString stringWithFormat:@"%d bytes", [[change objectForKey:@"new"] intValue]];
    }
    if ([keyPath isEqualToString:@"txCount"]) {
        self.txLabel.stringValue = [NSString stringWithFormat:@"%d bytes", [[change objectForKey:@"new"] intValue]];
    }
}

@end
