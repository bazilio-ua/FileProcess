//
//  FileProcessXPCServiceProtocol.h
//  FileProcessXPCService
//
//  Created by Vasyl Nikitiuk on 21.02.2021.
//

#import <Foundation/Foundation.h>

// The protocol that this service will vend as its API. This header file will also need to be visible to the process hosting the service.
@protocol FileProcessXPCServiceProtocol

// Replace the API of this protocol with an API appropriate to the service you are vending.
- (void)processFile:(NSURL *)aFile withReply:(void (^)(NSURL *, NSString *))reply;

@end
