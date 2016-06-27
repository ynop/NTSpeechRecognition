//
//  NTPocketSphinxRecognizer.m
//  NTSpeechRecognition
//
//  Created by Matthias Büchi on 27/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import "NTPocketSphinxRecognizer.h"

typedef NS_ENUM(NSUInteger, NTSpeechState) {
    NTSpeechStateNothing,
    NTSpeechStateUtterance,
    NTSpeechStateSpeech
};

@interface NTPocketSphinxRecognizer ()

@property (nonatomic) dispatch_queue_t decodeQueue;

@property (nonatomic) NTSpeechState speechState;

@end

@implementation NTPocketSphinxRecognizer

@synthesize audioSource = _audioSource;
@synthesize isStarted = _isStarted;
@synthesize isSuspended = _isSuspended;

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
        _decoder = decoder;
        self.audioSource = audioSource;
        self.decodeQueue = dispatch_queue_create("ch.zhaw.init.NTPocketSphinxRecognizer.decodeQueue", NULL);
        self.speechState = NTSpeechStateNothing;
    }
    return self;
}

#pragma mark - State
- (void)start
{
    _isStarted = YES;
}

- (void)stop
{
    _isStarted = NO;
}

- (void)suspend
{
    _isSuspended = YES;
}

- (void)resume
{
    _isSuspended = NO;
}

- (BOOL)isListening
{
    return self.isStarted && !self.isSuspended;
}

#pragma mark - Decoding
- (void)decodeData:(NSData*)data
{
    if (self.isListening) {
        if (self.speechState == NTSpeechStateNothing) {
            if ([self.decoder startUtterance]) {
                self.speechState = NTSpeechStateUtterance;
            }
            else {
                NSLog(@"Failed to start utterance. Stop decoding.");
                return;
            }
        }

        [self.decoder processData:(int16_t*)data.bytes samples:data.length / 2];

        BOOL containsSpeech = [self.decoder inSpeech];

        if (containsSpeech) {
            self.speechState = NTSpeechStateSpeech;
        }
        else {
            if (self.speechState == NTSpeechStateUtterance) {
                self.speechState = NTSpeechStateNothing;
                [self.decoder endUtterance];

                NTHypothesis* hyp = [self.decoder getHypothesis];
                NSLog(@"received hyp %@", hyp.value);
            }
        }
    }
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
    return [self.decoder setActiveSearchWithName:name];
}

- (NTSpeechSearch*)searchWithName:(NSString*)name
{
    return [self.decoder searchWithName:name];
}

@end
