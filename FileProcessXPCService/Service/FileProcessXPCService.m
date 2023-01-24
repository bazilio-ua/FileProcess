//
//  FileProcessXPCService.m
//  FileProcessXPCService
//
//  Created by Vasyl Nikitiuk on 21.02.2021.
//

#import <CommonCrypto/CommonCrypto.h>
#import "FileProcessXPCService.h"

@interface FileProcessXPCService ()

@property (nonatomic, weak) NSXPCConnection *connection;

@end

@implementation FileProcessXPCService

- (instancetype)initWithConnection:(NSXPCConnection *)connection {
    self = [super init];
    if (self) {
        [self setConnection:connection];
    }
    
    return self;
}

- (void)processFile:(NSURL *)aFile onCompletion:(void (^)(NSURL *, NSString *))replyFile {
    
    NSDictionary *fileResources = [aFile resourceValuesForKeys:@[NSURLFileSizeKey] error:nil];
    size_t size = [fileResources[NSURLFileSizeKey] longLongValue];
    
    id file = [NSFileHandle fileHandleForReadingFromURL:aFile error:nil];
    
    NSInteger bufferSize = 1024 * 1024;
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    
    NSLog(@"file %@ processing -> started...", aFile.lastPathComponent);
    [[self.connection remoteObjectProxy] startedProcessForFile:aFile];
    
    CC_SHA256_CTX context;
    CC_SHA256_Init(&context);
    
    while (true) {
        @autoreleasepool {
            size_t offset = [file offsetInFile];
            float percent = (float)offset / size * 100;
            
            NSLog(@"file %@ processing progress: %.2f%%", aFile.lastPathComponent, percent);
            [[self.connection remoteObjectProxy] updateProcessWithProgress:percent forFile:aFile];
            
            id chunkData = [file readDataOfLength:bufferSize];
            if ([chunkData length] > 0) {
                CC_SHA256_Update(&context, [chunkData bytes], (unsigned int)[chunkData length]);
            } else {
                break; // EOF
            }
        }
    }
    
    NSLog(@"file %@ processing -> finished.", aFile.lastPathComponent);
    [[self.connection remoteObjectProxy] finishedProcessForFile:aFile];
    
    CC_SHA256_Final(digest, &context);
    
    NSMutableString *hash = [NSMutableString string];
    for (int iterator = 0; iterator < sizeof(digest); iterator++) {
        [hash appendFormat:@"%02x", digest[iterator]];
    }
    
    NSLog(@"file %@ SHA256 hash is (%@)", aFile.lastPathComponent, hash);
    
    replyFile([aFile copy], [hash copy]);
}

- (void)deleteFile:(NSURL *)aFile onCompletion:(void (^)(NSURL *, BOOL))replyFile {
    
    NSLog(@"file %@ deleting -> started...", aFile.lastPathComponent);
    [[self.connection remoteObjectProxy] startedProcessForFile:aFile];
    
    BOOL result = [NSFileManager.defaultManager removeItemAtURL:aFile error:nil];
    
    NSLog(@"file %@ deleting -> finished.", aFile.lastPathComponent);
    [[self.connection remoteObjectProxy] finishedProcessForFile:aFile];
    
    NSLog(@"file %@ %@", aFile.lastPathComponent, result ? @"is deleted." : @"deletion error.");
    
    replyFile([aFile copy], result);
}

#pragma mark -
#pragma mark <FileProcessXPCServiceProtocol>

- (void)processFile:(NSURL *)aFile withDeletion:(BOOL)shouldDelete withReply:(void (^)(NSURL *, NSString *, BOOL))reply {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (shouldDelete == YES) {
            [self deleteFile:aFile onCompletion:^(NSURL *aFile, BOOL isDeleted) {
                reply(aFile, nil, isDeleted);
            }];
        } else {
            [self processFile:aFile onCompletion:^(NSURL *aFile, NSString *hash) {
                reply(aFile, hash, NO);
            }];
        }
    });
}

@end
