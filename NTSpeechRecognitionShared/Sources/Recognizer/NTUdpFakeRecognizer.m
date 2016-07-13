//
//  NTUdpFakeRecognizer.m
//  NTSpeechRecognition
//
//  Created by Matthias Büchi on 13/07/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import "NTUdpFakeRecognizer.h"
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>

UInt16 const FAKE_RECOGNIZER_UDP_DEFAULT_PORT = 45678;

@interface NTUdpFakeRecognizer () <GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) GCDAsyncUdpSocket* socket;

@property (nonatomic, strong) NSHashTable* delegates;

@property (nonatomic) UInt16 port;

@end

@implementation NTUdpFakeRecognizer

@synthesize audioSource = _audioSource;
@synthesize isStarted = _isStarted;
@synthesize isSuspended = _isSuspended;
@synthesize returnNullHypotheses = _returnNullHypotheses;
@synthesize returnPartialHypotheses = _returnPartialHypotheses;

- (instancetype)init
{
    return [self initWithAudioSource:nil];
}

- (instancetype)initWithPort:(UInt16)port
{
    return [self initWithAudioSource:nil port:port];
}

- (instancetype)initWithAudioSource:(NTAudioSource*)audioSource
{
    return [self initWithAudioSource:audioSource port:FAKE_RECOGNIZER_UDP_DEFAULT_PORT];
}

- (instancetype)initWithAudioSource:(NTAudioSource*)audioSource port:(UInt16)port
{
    self = [super init];
    if (self) {
        _delegates = [NSHashTable weakObjectsHashTable];
        self.audioSource = audioSource;
        self.socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

#pragma mark - State
- (void)start
{
    if (!_isStarted) {
        NSError* error = nil;

        if (![self.socket bindToPort:45678 error:&error]) {
            NSLog(@"Error binding: %@", error);
        }

        if (![self.socket beginReceiving:&error]) {
            NSLog(@"Error receiving: %@", error);
        }

        _isStarted = YES;
        [self notifyDidChangeListeningState:self.isListening];
    }
}

- (void)stop
{
    if (_isStarted) {
        [self.socket close];
        _isStarted = NO;
        [self notifyDidChangeListeningState:self.isListening];
    }
}

- (void)suspend
{
    if (_isStarted && !_isSuspended) {
        [self.socket pauseReceiving];
        _isSuspended = YES;
        [self notifyDidChangeListeningState:self.isListening];
    }
}

- (void)resume
{
    if (_isSuspended) {
        NSError* error = nil;

        if (![self.socket beginReceiving:&error]) {
            NSLog(@"Error receiving: %@", error);
        }
        _isSuspended = NO;
        [self notifyDidChangeListeningState:self.isListening];
    }
}

- (BOOL)isListening
{
    return self.isStarted && !self.isSuspended;
}

#pragma mark - Audio Source
- (void)setAudioSource:(NTAudioSource*)audioSource
{
}

- (void)audioSource:(NTAudioSource*)audioSource didReadData:(NSData*)data
{
}

#pragma mark - UDP Socket delegate
- (void)udpSocket:(GCDAsyncUdpSocket*)sock didReceiveData:(NSData*)data fromAddress:(NSData*)address withFilterContext:(id)filterContext
{
    NSString* hypothesis = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (hypothesis) {
        if ([hypothesis isEqualToString:@"__SUSPEND__"]) {
            [self suspend];
        }
        else if ([hypothesis isEqualToString:@"__RESUME__"]) {
            [self resume];
        }
        else if (!self.isSuspended) {
            [self notifyHypothesisReceived:[NTHypothesis hypothesis:hypothesis]];
        }
    }
}

#pragma mark - Dictionary
- (NTPronunciationDictionary*)dictionary
{
    return nil;
}

- (BOOL)loadPronunciationDictioanry:(NTPronunciationDictionary*)dictionary
{
    return YES;
}

- (BOOL)addWord:(NSString*)word phones:(NSString*)phones
{
    return YES;
}

- (BOOL)addWord:(NSString*)word listOfPhones:(NSArray*)listOfPhones
{
    return YES;
}

- (BOOL)addWords:(NSDictionary*)words
{
    return YES;
}

#pragma mark - Searches
- (NSArray*)searches
{
    return @[];
}

- (NTSpeechSearch*)activeSearch
{
    return nil;
}

- (BOOL)addSearch:(NTSpeechSearch*)search
{
    return YES;
}

- (void)removeSearch:(NTSpeechSearch*)search
{
}

- (void)removeSearchByName:(NSString*)name
{
}

- (BOOL)setActiveSearchByName:(NSString*)name
{
    return YES;
}

- (NTSpeechSearch*)searchWithName:(NSString*)name
{
    return nil;
}

#pragma mark - Delegates
- (void)notifyHypothesisReceived:(NTHypothesis*)hyp
{
    for (id<NTSpeechRecognizerDelegate> delegate in self.delegates) {
        [delegate speechRecognizer:self didReceiveHypothesis:hyp forSearch:self.activeSearch];
    }
}

- (void)notifyPartialHypothesisReceived:(NTHypothesis*)hyp
{
    for (id<NTSpeechRecognizerDelegate> delegate in self.delegates) {
        [delegate speechRecognizer:self didReceivePartialHypothesis:hyp forSearch:self.activeSearch];
    }
}

- (void)notifyDidChangeListeningState:(BOOL)state
{
    for (id<NTSpeechRecognizerDelegate> delegate in self.delegates) {
        [delegate speechRecognizer:self didChangeListeningState:state];
    }
}

- (void)addDelegate:(id<NTSpeechRecognizerDelegate>)delegate
{
    [self.delegates addObject:delegate];
}

- (void)removeDelegate:(id<NTSpeechRecognizerDelegate>)delegate
{
    [self.delegates removeObject:delegate];
}

@end
