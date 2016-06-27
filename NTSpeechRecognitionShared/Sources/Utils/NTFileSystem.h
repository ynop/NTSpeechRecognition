//
//  NTFileSystem.h
//  NTSpeechRecognition
//
//  Created by Matthias Büchi on 22/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTFileSystem : NSObject

+ (NSString*)getTempFilePath;

+ (NSURL*)createTempDirectory;

@end
