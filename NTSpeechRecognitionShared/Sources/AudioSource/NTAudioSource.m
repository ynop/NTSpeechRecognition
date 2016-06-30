//
//  NTAudioSource.m
//  NTSpeechRecognition
//
//  Created by Matthias Büchi on 24/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import "NTAudioSource.h"

@interface NTAudioSource ()

@property (nonatomic, strong) NSHashTable* delegates;

@end

@implementation NTAudioSource

- (instancetype)init
{
    return [self initWithFormat:[NTAudioSource monoPCM16kInt16]];
}

- (instancetype)initWithFormat:(AudioStreamBasicDescription)format
{
    self = [super init];
    if (self) {
        _delegates = [NSHashTable weakObjectsHashTable];
        _format = format;

        _started = NO;
        _suspended = NO;
    }
    return self;
}

#pragma mark - Processing
- (BOOL)start
{
    return NO;
}

- (BOOL)suspend
{
    return NO;
}

- (BOOL)resume
{
    return NO;
}

- (BOOL)stop
{
    return NO;
}

#pragma mark - Delegates
- (void)addDelegate:(id<NTAudioSourceDelegate>)delegate
{
    [self.delegates addObject:delegate];
}

- (void)removeDelegate:(id<NTAudioSourceDelegate>)delegate
{
    [self.delegates removeObject:delegate];
}

#pragma mark - Subclassing
- (void)notifyDelegatesDidReadData:(NSData*)data
{
    for (id<NTAudioSourceDelegate> delegate in self.delegates) {
        [delegate audioSource:self didReadData:data];
    }
}

#pragma mark - Formats
+ (AudioStreamBasicDescription)monoPCM16kInt16
{
    AudioStreamBasicDescription targetFormat;
    targetFormat.mSampleRate = 16000;
    targetFormat.mFormatID = kAudioFormatLinearPCM;
    targetFormat.mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsNonInterleaved;
    targetFormat.mBytesPerPacket = 2;
    targetFormat.mFramesPerPacket = 1;
    targetFormat.mBytesPerFrame = 2;
    targetFormat.mChannelsPerFrame = 1;
    targetFormat.mBitsPerChannel = 16;
    targetFormat.mReserved = 0;

    return targetFormat;
}

@end
