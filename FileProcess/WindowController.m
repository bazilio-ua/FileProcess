//
//  WindowController.m
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 19.02.2021.
//

#import "WindowController.h"
#import "ViewController.h"
#import "FileProcessXPCServiceProtocol.h"

@interface WindowController ()

@property (nonatomic, strong) NSXPCConnection *connectionToService;

@end

@implementation WindowController

- (void)close {
    [super close];
    
    [self.connectionToService invalidate];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    ViewController *controller = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    [controller setDelegate:self];
    self.window.contentViewController = controller;
    
    [self setConnectionToService:[[NSXPCConnection alloc] initWithServiceName:@"org.ua.fixme.FileProcessXPCService"]];
    [self.connectionToService setRemoteObjectInterface:[NSXPCInterface interfaceWithProtocol:@protocol(FileProcessXPCServiceProtocol)]];
    
    [self.connectionToService setExportedInterface:[NSXPCInterface interfaceWithProtocol:@protocol(FileProcessXPCServiceProgressProtocol)]];
    [self.connectionToService setExportedObject:controller];
    
    [self.connectionToService setInterruptionHandler:^{
        NSLog(@"connection to process was interrupted");
    }];
    [self.connectionToService setInvalidationHandler:^{
        NSLog(@"connection to process was invalidated");
    }];
    [self.connectionToService resume];

}

- (void)openDocument:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel new];
    [openPanel setShowsHiddenFiles:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowsMultipleSelection:YES];
    
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            [self.contentViewController setRepresentedObject:openPanel.URLs];
        }
    }];
}

#pragma mark -
#pragma mark <FileProcessorProtocol>

- (void)processFile:(NSURL *)file onCompletion:(void (^)(NSURL *, NSString *))processedFile {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[self.connectionToService remoteObjectProxy] processFile:file withReply:^(NSURL *aFile, NSString *hash) {
            processedFile(aFile, hash);
        }];
    });
}

@end
