//
//  ServiceDelegate.m
//  FileProcessXPCService
//
//  Created by Vasyl Nikitiuk on 27.02.2021.
//

#import "ServiceDelegate.h"

@interface ServiceDelegate ()

@end

@implementation ServiceDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(FileProcessXPCServiceProtocol)];
    newConnection.exportedObject = [[FileProcessXPCService alloc] initWithConnection:newConnection];
    newConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(FileProcessXPCServiceProgressProtocol)];
    [newConnection resume];
    
    return YES;
}

@end
