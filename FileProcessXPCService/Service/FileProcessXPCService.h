//
//  FileProcessXPCService.h
//  FileProcessXPCService
//
//  Created by Vasyl Nikitiuk on 21.02.2021.
//

#import <Foundation/Foundation.h>
#import "FileProcessXPCServiceProtocol.h"

@interface FileProcessXPCService : NSObject <FileProcessXPCServiceProtocol>

- (instancetype)initWithConnection:(NSXPCConnection *)connection;

@end
