//
//  FileProcessXPCService.m
//  FileProcessXPCService
//
//  Created by Vasyl Nikitiuk on 21.02.2021.
//

#import <CommonCrypto/CommonCrypto.h>
#import "FileProcessXPCService.h"

@implementation FileProcessXPCService

// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.

- (void)processFile:(NSURL *)aFile withReply:(void (^)(NSURL *, NSString *))reply {
    
    id file = [NSFileHandle fileHandleForReadingFromURL:aFile error:nil];
    
    NSInteger bufferSize = 1024 * 1024;
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256_CTX context;
    CC_SHA256_Init(&context);
    
    while (true) {
        @autoreleasepool {
            id chunkData = [file readDataOfLength:bufferSize];
            if ([chunkData length] > 0) {
                CC_SHA256_Update(&context, [chunkData bytes], (unsigned int)[chunkData length]);
            } else
                break; // EOF
        }
    }
    
    CC_SHA256_Final(digest, &context);
    
    NSMutableString *hash = [NSMutableString string];
    for (int iterator = 0; iterator < sizeof(digest); iterator++) {
        [hash appendFormat:@"%02x", digest[iterator]];
    }
    
    NSLog(@"file: %@", aFile);
    NSLog(@"hash: %@", hash);
    
    reply([aFile copy], [hash copy]);
}

@end
