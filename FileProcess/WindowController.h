//
//  WindowController.h
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 19.02.2021.
//

#import <Cocoa/Cocoa.h>
#import "FileProcessorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WindowController : NSWindowController <FileProcessorProtocol>

- (void)openDocument:(id)sender;

@end

NS_ASSUME_NONNULL_END
