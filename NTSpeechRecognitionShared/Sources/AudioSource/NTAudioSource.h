//
//  NTAudioSource.h
//  NTSpeechRecognition
//
//  Created by Matthias Büchi on 24/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NTAudioSource;

@protocol NTAudioSourceDelegate <NSObject>

- (void)audioSource:(NTAudioSource*)audioSource didReadData:(NSData*)data;

@end

@interface NTAudioSource : NSObject

@property (nonatomic, readonly) BOOL started;
@property (nonatomic, readonly) BOOL suspended;

#pragma mark - Processing
- (BOOL)start;

- (BOOL)suspend;

- (BOOL)resume;

- (BOOL)stop;

#pragma mark - Delegates
- (void)addDelegate:(id<NTAudioSourceDelegate>)delegate;

- (void)removeDelegate:(id<NTAudioSourceDelegate>)delegate;

#pragma mark - Subclassing
- (void)notifyDelegatesDidReadData:(NSData*)data;

@end
