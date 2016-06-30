//
//  NTFileSystem.h
//  NTSpeechRecognition
//
//  Created by Matthias Büchi on 22/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTFileSystem : NSObject

/*!
 *  Generates the path (No file!) for a temporary file in the TEMP directory.
 *
 *  @return Path
 */
+ (NSString*)getTempFilePath;

/*!
 *  Creates a random folder in the TEMP directory.
 *
 *  @return Path to the directory
 */
+ (NSURL*)createTempDirectory;

@end
