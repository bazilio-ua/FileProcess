//
//  AppDelegate.m
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 19.02.2021.
//

#import "AppDelegate.h"
#import "WindowController.h"
#import "FileProcessXPCServiceProtocol.h"

@interface AppDelegate ()

@property (nonatomic, strong) WindowController *windowController;
@property (nonatomic, strong) NSXPCConnection *connectionToService;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [self setWindowController:[[WindowController alloc] initWithWindowNibName:@"WindowController"]];
    [self.windowController showWindow:nil];
    
    [self setConnectionToService:[[NSXPCConnection alloc] initWithServiceName:@"org.ua.fixme.FileProcessXPCService"]];
    [self.connectionToService setRemoteObjectInterface:[NSXPCInterface interfaceWithProtocol:@protocol(FileProcessXPCServiceProtocol)]];
    [self.connectionToService setInterruptionHandler:^{
        NSLog(@"connection to process was interrupted");
    }];
    [self.connectionToService setInvalidationHandler:^{
        NSLog(@"connection to process was invalidated");
    }];
    [self.connectionToService resume];
    
    [[self.connectionToService remoteObjectProxy] upperCaseString:@"hello" withReply:^(NSString *aString) {
        // We have received a response. Update our text field, but do it on the main thread.
        NSLog(@"Result string was: %@", aString);
    }];

}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    
    [self.connectionToService invalidate];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (IBAction)openDocument:(id)sender {
    [self.windowController openDocument:sender];
}

@end
