//
//  main.m
//  FileProcessXPCService
//
//  Created by Vasyl Nikitiuk on 21.02.2021.
//

#import <Foundation/Foundation.h>
#import "ServiceDelegate.h"

int main(int argc, const char *argv[]) {
    
    ServiceDelegate *delegate = [ServiceDelegate new];
    
    NSXPCListener *listener = [NSXPCListener serviceListener];
    listener.delegate = delegate;
    [listener resume];
    
    return 0;
}
