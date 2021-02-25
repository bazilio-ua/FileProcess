//
//  FileProcessorProtocol.h
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 25.02.2021.
//

#import <Foundation/Foundation.h>

@protocol FileProcessorProtocol <NSObject>

- (void)processFile:(NSURL *)file onCompletion:(void (^)(NSURL *, NSString *))processedFile;

@end
