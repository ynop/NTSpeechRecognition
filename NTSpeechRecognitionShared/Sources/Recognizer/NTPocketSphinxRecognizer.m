//
//  NTPocketSphinxRecognizer.m
//  NTSpeechRecognition
//
//  Created by Matthias Büchi on 27/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import "NTPocketSphinxRecognizer.h"

@interface NTPocketSphinxRecognizer ()

@property (nonatomic) dispatch_queue_t decodeQueue;

/*!
 *  The time is elapsed since the silence began.
 */
@property (nonatomic) CFTimeInterval timeSinceSilenceStarted;

/*!
 *  Whether an utterance was started or not.
 */
@property (nonatomic) BOOL utteranceStarted;

/*!
 *  Whether the decoder detected speech during the current utterance.
 */
@property (nonatomic) BOOL speechDetectedWithinUtterance;

/*!
 *  List of delegates
 */
@property (nonatomic, strong) NSHashTable* delegates;

@end

@implementation NTPocketSphinxRecognizer

@synthesize audioSource = _audioSource;
@synthesize isStarted = _isStarted;
@synthesize isSuspended = _isSuspended;
@synthesize returnNullHypotheses = _returnNullHypotheses;
@synthesize returnPartialHypotheses = _returnPartialHypotheses;

- (instancetype)init
{
    return [self initWithAudioSource:nil];
}

- (instancetype)initWithAudioSource:(NTAudioSource*)audioSource
{
    return [self initWithPocketSphinxDecoder:[NTPocketSphinxDecoder new] audioSource:audioSource];
}

- (instancetype)initWithPocketSphinxDecoder:(NTPocketSphinxDecoder*)decoder
{
    return [self initWithPocketSphinxDecoder:decoder audioSource:nil];
}

- (instancetype)initWithPocketSphinxDecoder:(NTPocketSphinxDecoder*)decoder audioSource:(NTAudioSource*)audioSource
{
    self = [super init];
    if (self) {
        _delegates = [NSHashTable weakObjectsHashTable];
        _decoder = decoder;
        self.audioSource = audioSource;
        self.decodeQueue = dispatch_queue_create("ch.zhaw.init.NTPocketSphinxRecognizer.decodeQueue", NULL);
        self.sampleRate = 16000;
        self.pauseThreshold = 0.5;
    }
    return self;
}

- (void)dealloc
{
}

#pragma mark - State
- (void)start
{
    if (!self.isStarted) {
        [self resetStateForDecoding];
        _isStarted = YES;
        [self notifyDidChangeListeningState:self.isListening];
    }
    else {
        NSLog(@"Already started recognizer!");
    }
}

- (void)stop
{
    if (self.isStarted) {
        _isStarted = NO;

        dispatch_async(self.decodeQueue, ^{
            [self forceEndUtterance];
        });

        [self notifyDidChangeListeningState:self.isListening];
    }
    else {
        NSLog(@"Recognizer isn't started, can't stop!");
    }
}

- (void)suspend
{
    if (self.isListening) {
        _isSuspended = YES;

        dispatch_async(self.decodeQueue, ^{
            [self forceEndUtterance];
        });

        [self notifyDidChangeListeningState:self.isListening];
    }
    else {
        NSLog(@"Recognizer not listening, can't suspend recognition!");
    }
}

- (void)resume
{
    if (self.isSuspended) {
        [self resetStateForDecoding];
        _isSuspended = NO;

        dispatch_async(self.decodeQueue, ^{
            [self forceEndUtterance];
        });

        [self notifyDidChangeListeningState:self.isListening];
    }
    else {
        NSLog(@"Recognizer not suspended, can't resume!");
    }
}

- (BOOL)isListening
{
    return self.isStarted && !self.isSuspended;
}

#pragma mark - Decoding (Executed via dispatch queue)
- (void)forceEndUtterance
{
    if (self.utteranceStarted) {
        [self.decoder endUtterance];
        [self resetStateForDecoding];

        NSLog(@"Ending utterance");
    }
}

- (void)changeActiveSearch:(NSString*)name
{
    if (self.utteranceStarted) {
        [self.decoder endUtterance];
        [self resetStateForDecoding];
    }

    [self.decoder setActiveSearchWithName:name];
}

- (void)decodeData:(NSData*)data
{
    if (self.isListening) {
        unsigned long nrOfSamples = data.length / 2;
        CFTimeInterval duration = ((double)nrOfSamples) / ((double)self.sampleRate);

        // BEGIN UTTERANCE
        if (!self.utteranceStarted) {
            if ([self.decoder startUtterance]) {
                NSLog(@"Starting utterance");
                self.utteranceStarted = YES;
                self.speechDetectedWithinUtterance = NO;
                self.timeSinceSilenceStarted = 0;
            }
            else {
                NSLog(@"Failed to start utterance. Stop decoding.");
                return;
            }
        }

        // PROCESS SAMPLES
        int nrSamplesProcessed = [self.decoder processData:(SInt16*)data.bytes samples:nrOfSamples];

        if (nrSamplesProcessed < 0) {
            NSLog(@"Failed to decode data chunk.");
        }

        BOOL containsSpeech = [self.decoder inSpeech];

        // CHECK FOR SPEECH
        if (containsSpeech) {
            if (!self.speechDetectedWithinUtterance) {
                self.speechDetectedWithinUtterance = YES;

                NSLog(@"Detected Speech");
            }
            self.timeSinceSilenceStarted = 0;
        }
        else {
            self.timeSinceSilenceStarted += duration;
        }

        // END UTTERANCE WHEN PAUSE DETECTED
        if (self.speechDetectedWithinUtterance && self.timeSinceSilenceStarted >= self.pauseThreshold) {
            [self.decoder endUtterance];
            [self resetStateForDecoding];

            NSLog(@"Ending utterance");

            NTHypothesis* hyp = [self.decoder getHypothesis];

            if (self.returnNullHypotheses || ![hyp isNull]) {
                [self notifyHypothesisReceived:hyp];
            }
        }
        // OTHERWISE RETURN PARTIAL HYP IF THERE WAS SPEECH IN THIS DATA CHUNK
        else if (containsSpeech && self.returnPartialHypotheses) {
            NTHypothesis* hyp = [self.decoder getHypothesis];

            if (self.returnNullHypotheses || ![hyp isNull]) {
                [self notifyPartialHypothesisReceived:hyp];
            }
        }
    }
}

- (void)resetStateForDecoding
{
    self.utteranceStarted = NO;
    self.speechDetectedWithinUtterance = NO;
    self.timeSinceSilenceStarted = 0;
}

#pragma mark - Audio Source
- (void)setAudioSource:(NTAudioSource*)audioSource
{
    if (audioSource != _audioSource) {
        [_audioSource removeDelegate:self];
        _audioSource = audioSource;
        [_audioSource addDelegate:self];
    }
}

- (void)audioSource:(NTAudioSource*)audioSource didReadData:(NSData*)data
{
    dispatch_async(self.decodeQueue, ^{
        [self decodeData:data];
    });
}

#pragma mark - Dictionary
- (NTPronunciationDictionary*)dictionary
{
    return self.decoder.dictionary;
}

- (BOOL)loadPronunciationDictioanry:(NTPronunciationDictionary*)dictionary
{
    return [self.decoder loadPronunciationDictionary:dictionary];
}

- (BOOL)addWord:(NSString*)word phones:(NSString*)phones
{
    return [self.decoder addWord:word withPhones:phones update:YES];
}

- (BOOL)addWord:(NSString*)word listOfPhones:(NSArray*)listOfPhones
{
    BOOL success = YES;

    for (NSString* phones in listOfPhones) {
        if (![self addWord:word phones:phones]) {
            success = NO;
        }
    }

    return success;
}

- (BOOL)addWords:(NSDictionary*)words
{
    BOOL success = YES;

    for (NSString* word in words.allKeys) {
        if (![self addWord:word listOfPhones:words[word]]) {
            success = NO;
        }
    }
    return success;
}

#pragma mark - Searches
- (NSArray*)searches
{
    return self.decoder.searches;
}

- (NTSpeechSearch*)activeSearch
{
    return self.decoder.activeSearch;
}

- (BOOL)addSearch:(NTSpeechSearch*)search
{
    return [self.decoder addSearch:search];
}

- (void)removeSearch:(NTSpeechSearch*)search
{
    [self.decoder removeSearchWithName:search.name];
}

- (void)removeSearchByName:(NSString*)name
{
    [self.decoder removeSearchWithName:name];
}

- (BOOL)setActiveSearchByName:(NSString*)name
{
    if ([self searchWithName:name]) {

        dispatch_async(self.decodeQueue, ^{
            [self changeActiveSearch:name];
        });

        return YES;
    }
    else {
        return NO;
    }
}

- (NTSpeechSearch*)searchWithName:(NSString*)name
{
    return [self.decoder searchWithName:name];
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
