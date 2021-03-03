//
//  FileModel.m
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 02.03.2021.
//

#import "FileModel.h"

@interface FileModel ()

@property (nonatomic, strong) NSDictionary *fileResources;

+ (NSArray *)fileKeys;
+ (NSDirectoryEnumerationOptions)fileOption;

@end

@implementation FileModel

+ (NSArray *)fileKeys {
    return @[NSURLLocalizedNameKey,
             NSURLEffectiveIconKey,
             NSURLIsPackageKey,
             NSURLIsDirectoryKey,
             NSURLFileSizeKey,
             NSURLContentModificationDateKey,
             NSURLTypeIdentifierKey];
}

+ (NSDirectoryEnumerationOptions)fileOption {
    return NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants;
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        
        self.url = url;
        
        NSDictionary *fileResources = [url resourceValuesForKeys:FileModel.fileKeys error:nil];
        [self setFileResources:fileResources];
        
        self.name = fileResources[NSURLLocalizedNameKey];
        self.icon = fileResources[NSURLEffectiveIconKey];
        self.type = fileResources[NSURLTypeIdentifierKey];
        self.date = fileResources[NSURLContentModificationDateKey];
        self.size = [fileResources[NSURLFileSizeKey] unsignedLongLongValue];
        
        self.directory = [fileResources[NSURLIsDirectoryKey] boolValue];
        self.package = [fileResources[NSURLIsPackageKey] boolValue];
        
        self.status = kFileUnprocessed;
        self.check = YES;
        
        self.deleted = NO;
    }
    
    return self;
}

- (NSDirectoryEnumerator *)directoryEnumerator {
    NSDirectoryEnumerator *result = nil;
    if ([self isDirectory]) {
        result = [NSFileManager.defaultManager enumeratorAtURL:self.url
                                    includingPropertiesForKeys:FileModel.fileKeys
                                                       options:FileModel.fileOption
                                                  errorHandler:nil];
    }
    
    return result;
}

@end
