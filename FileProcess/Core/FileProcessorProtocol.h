//
//  FileProcessorProtocol.h
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 25.02.2021.
//

#import <Foundation/Foundation.h>

@protocol FileProcessorProtocol <NSObject>

- (void)processFile:(NSURL *)file withDeletion:(BOOL)shouldDelete onCompletion:(void (^)(NSURL *, NSString *, BOOL))processedFile;
- (void)openFile:(id)sender;

@end
