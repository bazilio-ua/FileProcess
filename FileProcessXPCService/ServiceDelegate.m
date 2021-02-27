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
    // This method is where the NSXPCListener configures, accepts, and resumes a new incoming NSXPCConnection.
    
    // Configure the connection.
    // First, set the interface that the exported object implements.
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(FileProcessXPCServiceProtocol)];
    
    // Next, set the object that the connection exports. All messages sent on the connection to this service will be sent to the exported object to handle. The connection retains the exported object.
    newConnection.exportedObject = [[FileProcessXPCService alloc] initWithConnection:newConnection];
    
    // (exported from the other side). This value is required if messages are sent over this connection.
    newConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(FileProcessXPCServiceProgressProtocol)];
    
    // Resuming the connection allows the system to deliver more incoming messages.
    [newConnection resume];
    
    // Returning YES from this method tells the system that you have accepted this connection. If you want to reject the connection for some reason, call -invalidate on the connection and return NO.
    return YES;
}

@end
