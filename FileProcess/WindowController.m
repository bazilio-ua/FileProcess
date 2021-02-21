//
//  WindowController.m
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 19.02.2021.
//

#import "WindowController.h"
#import "ViewController.h"

@interface WindowController ()

@end

@implementation WindowController


- (void)windowDidLoad {
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    ViewController *controller = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.contentViewController = controller;
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


@end
