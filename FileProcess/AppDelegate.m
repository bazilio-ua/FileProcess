//
//  AppDelegate.m
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 19.02.2021.
//

#import "AppDelegate.h"
#import "WindowController.h"

@interface AppDelegate ()

@property (nonatomic, strong) WindowController *windowController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [self setWindowController:[[WindowController alloc] initWithWindowNibName:@"WindowController"]];
    [self.windowController showWindow:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
    [self.windowController close];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (IBAction)openDocument:(id)sender {
    [self.windowController openDocument:sender];
}

@end
