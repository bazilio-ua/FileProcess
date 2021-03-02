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
    }
    
    return self;
}


@end
