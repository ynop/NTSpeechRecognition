//
//  NTMicrophoneAudioSource.m
//  NTSpeechRecognizer
//
//  Created by Matthias Büchi on 24/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import "NTMicrophoneAudioSource.h"

static void inputCallback(
    void* inRef,
    AudioQueueRef inAQ,
    AudioQueueBufferRef inBuffer,
    const AudioTimeStamp* inStartTime,
    UInt32 inNumPackets,
    const AudioStreamPacketDescription* inPacketDesc);

@interface NTMicrophoneAudioSource ()

@property (nonatomic) AudioQueueRef audioQueue;
@property (nonatomic) AudioQueueBufferRef* audioQueueBuffers;
@property (nonatomic) int numberOfBuffers;
@property (nonatomic) UInt32 bufferSizeBytes;

@end

@implementation NTMicrophoneAudioSource

- (instancetype)init
{
    return [self initWithFormat:[NTMicrophoneAudioSource pocketsphinxFormat]];
}

- (instancetype)initWithFormat:(AudioStreamBasicDescription)format
{
    self = [super init];
    if (self) {
        _format = format;
        _numberOfBuffers = 5;
    }
    return self;
}

- (void)dealloc
{
    free(self.audioQueueBuffers);
    AudioQueueDispose(self.audioQueue, true);
}

#pragma mark - Processing
- (BOOL)start
{
    BOOL success = [self setupQueue];

    if (success) {
        OSStatus status = AudioQueueStart(self.audioQueue, NULL);
        success = [self checkOSStatus:status message:@"Failed to start AudioQueue!"];
    }

    return success;
}

- (BOOL)stop
{
    OSStatus status = AudioQueueStop(self.audioQueue, true);
    return [self checkOSStatus:status message:@"Failed to start AudioQueue!"];
}

- (BOOL)suspend
{
    OSStatus status = AudioQueueStop(self.audioQueue, true);
    return [self checkOSStatus:status message:@"Failed to start AudioQueue!"];
}

- (BOOL)resume
{
    OSStatus status = AudioQueueStart(self.audioQueue, NULL);
    return [self checkOSStatus:status message:@"Failed to start AudioQueue!"];
}

#pragma mark - configuration
- (BOOL)setupQueue
{
    OSStatus status = AudioQueueNewInput(&_format, inputCallback, (__bridge void*)(self), NULL, kCFRunLoopCommonModes, 0, &_audioQueue);
    BOOL success = [self checkOSStatus:status message:@"Failed to create AudioQueue!"];

    if (success) {
        [self deriveBufferSizeForSeconds:0.1];
        success = [self initializeBuffers];
    }

    return success;
}

- (void)deriveBufferSizeForSeconds:(double)seconds
{
    static const int maxBufferSize = 0x50000;

    int maxPacketSize = self.format.mBytesPerPacket;
    if (maxPacketSize == 0) {
        UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
        AudioQueueGetProperty(self.audioQueue, kAudioQueueProperty_MaximumOutputPacketSize, &maxPacketSize, &maxVBRPacketSize);
    }

    Float64 numBytesForTime = self.format.mSampleRate * maxPacketSize * seconds;
    self.bufferSizeBytes = (UInt32)(numBytesForTime < maxBufferSize ? numBytesForTime : maxBufferSize); // 9
}

- (BOOL)initializeBuffers
{
    BOOL ret = YES;

    self.audioQueueBuffers = (AudioQueueBufferRef*)malloc(self.numberOfBuffers * self.bufferSizeBytes);

    for (int i = 0; i < self.numberOfBuffers; i++) {
        OSStatus status = AudioQueueAllocateBuffer(self.audioQueue, self.bufferSizeBytes, &_audioQueueBuffers[i]);
        BOOL successAllocation = [self checkOSStatus:status message:@"Failed to allocate AudioQueueBuffer!"];

        status = AudioQueueEnqueueBuffer(self.audioQueue, _audioQueueBuffers[i], 0, NULL);
        BOOL successEnqueue = [self checkOSStatus:status message:@"Failed to enqueue AudioQueueBuffer!"];

        if (!successAllocation || !successEnqueue) {
            ret = NO;
        }
    }

    return ret;
}

- (BOOL)checkOSStatus:(OSStatus)status message:(NSString*)message
{
    if (status != noErr) {
        NSLog(@"Error %i : %@", status, message);
    }

    return status == noErr;
}

+ (AudioStreamBasicDescription)pocketsphinxFormat
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

#pragma mark - CALLBACKS
static void inputCallback(
    void* inRef,
    AudioQueueRef inAQ,
    AudioQueueBufferRef inBuffer,
    const AudioTimeStamp* inStartTime,
    UInt32 inNumPackets,
    const AudioStreamPacketDescription* inPacketDesc)
{
    NTMicrophoneAudioSource* audioSource = (__bridge NTMicrophoneAudioSource*)inRef;

    NSData* data = [NSData dataWithBytes:inBuffer->mAudioData length:inNumPackets * 2];
    [audioSource notifyDelegatesDidReadData:data];

    if (inNumPackets == 0 && audioSource.format.mBytesPerPacket != 0) {
        inNumPackets = inBuffer->mAudioDataByteSize / audioSource.format.mBytesPerPacket;
    }

    AudioQueueEnqueueBuffer(audioSource.audioQueue, inBuffer, 0, NULL);
}

@end
