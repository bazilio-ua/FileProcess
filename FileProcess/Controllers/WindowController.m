//
//  WindowController.m
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 19.02.2021.
//

#import "WindowController.h"
#import "ViewController.h"
#import "FileModel.h"
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
            
            NSMutableArray<FileModel *> *files = [NSMutableArray array];
            for (NSURL *url in openPanel.URLs) {
                [files addObject:[[FileModel alloc] initWithURL:url]];
            }
            
            [self.contentViewController setRepresentedObject:[files copy]];
        }
    }];
}

#pragma mark -
#pragma mark <FileProcessorProtocol>

- (void)processFile:(NSURL *)file withDeletion:(BOOL)shouldDelete onCompletion:(void (^)(NSURL *, NSString *, BOOL))processedFile {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[self.connectionToService remoteObjectProxy] processFile:file
                                                     withDeletion:shouldDelete
                                                        withReply:^(NSURL *aFile, NSString *hash, BOOL isDeleted) {
            processedFile(aFile, hash, isDeleted);
        }];
    });
}

- (void)openFile:(id)sender {
    [self openDocument:sender];
}

@end
