//
//  FileProcessXPCService.h
//  FileProcessXPCService
//
//  Created by Vasyl Nikitiuk on 21.02.2021.
//

#import <Foundation/Foundation.h>
#import "FileProcessXPCServiceProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface FileProcessXPCService : NSObject <FileProcessXPCServiceProtocol>

@end
