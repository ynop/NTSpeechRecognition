//
//  NTFileSystem.m
//  NTSpeechRecognition
//
//  Created by Matthias Büchi on 22/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import "NTFileSystem.h"

@implementation NTFileSystem

+ (NSString*)getTempFilePath
{
    NSString* tempFolder = NSTemporaryDirectory();
    NSString* tempFileName = [NSUUID UUID].UUIDString;

    return [tempFolder stringByAppendingPathComponent:tempFileName];
}

+ (NSURL*)createTempDirectory
{
    NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    NSURL* directoryURL = [NSURL fileURLWithPath:path isDirectory:YES];

    NSError* error = nil;

    [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error];

    if (nil != error) {
        NSLog(@"Error while creating new temp directory: %@", error);
        return nil;
    }

    return directoryURL;
}

@end
