//
//  NTAudioSource.m
//  NTSpeechRecognizer
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
    self = [super init];
    if (self) {
        _delegates = [NSHashTable weakObjectsHashTable];

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

@end
