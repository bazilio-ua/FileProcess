//
//  FileProcessXPCServiceProtocol.h
//  FileProcessXPCService
//
//  Created by Vasyl Nikitiuk on 21.02.2021.
//

#import <Foundation/Foundation.h>

@protocol FileProcessXPCServiceProtocol

- (void)processFile:(NSURL *)aFile withDeletion:(BOOL)shouldDelete withReply:(void (^)(NSURL *, NSString *, BOOL))reply;

@end

@protocol FileProcessXPCServiceProgressProtocol

- (void)startedProcessForFile:(NSURL *)aFile;
- (void)updateProcessWithProgress:(float)percentage forFile:(NSURL *)aFile;
- (void)finishedProcessForFile:(NSURL *)aFile;

@end
