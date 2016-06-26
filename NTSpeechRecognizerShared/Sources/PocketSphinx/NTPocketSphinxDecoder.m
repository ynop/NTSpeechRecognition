//
//  NTPocketSphinxDecoder.m
//  NTSpeechRecognizer
//
//  Created by Matthias Büchi on 21/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import "NTFileSystem.h"
#import "NTPocketSphinxDecoder.h"
#import "pocketsphinx.h"

@interface NTPocketSphinxDecoder ()

@property (nonatomic) ps_decoder_t* decoder;

@property (nonatomic, strong) NSMutableDictionary<NSString*, NTSpeechSearch*>* internalSearches;

@end

@implementation NTPocketSphinxDecoder

- (instancetype)init
{
    //TODO: define default confi
    NTPocketSphinxConfig* default_config = [NTPocketSphinxConfig new];

    return [self initWithConfiguration:default_config];
}

- (instancetype)initWithConfiguration:(NTPocketSphinxConfig*)config
{
    self = [super init];
    if (self) {
        _internalSearches = [NSMutableDictionary dictionary];

        self.decoder = ps_init((cmd_ln_t*)config.ps_config);
        _config = config;
    }
    return self;
}

#pragma mark - Configuration
- (BOOL)reinitWithConfiguration:(NTPocketSphinxConfig*)config
{
    int success = ps_reinit(self.decoder, (cmd_ln_t*)config.ps_config);

    if (!success) {
        _config = config;
    }

    return !success;
}

#pragma mark - Pronounciation Dictionary
- (BOOL)loadPronunciationDictionaryFromFile:(NSString*)pronunciationDictPath
{
    return [self loadPronunciationDictionaryFromFile:pronunciationDictPath andFillerDictionary:nil];
}

- (BOOL)loadPronunciationDictionaryFromFile:(NSString*)pronunciationDictPath andFillerDictionary:(NSString*)fillerDictPath
{
    const char* cDictPath = [pronunciationDictPath cStringUsingEncoding:NSUTF8StringEncoding];
    int success = 1;

    if (fillerDictPath) {
        const char* cFillerPath = [fillerDictPath cStringUsingEncoding:NSUTF8StringEncoding];

        success = ps_load_dict(self.decoder, cDictPath, cFillerPath, NULL);
    }
    else {
        success = ps_load_dict(self.decoder, cDictPath, NULL, NULL);
    }

    if (success) {
        _dictionary = [[NTPronunciationDictionary alloc] initWithName:@"default" fileAtPath:pronunciationDictPath];
    }

    return !success;
}

- (BOOL)loadPronunciationDictionary:(NTPronunciationDictionary*)dictionary
{
    NSString* tempDictPath = [NTFileSystem getTempFilePath];
    [dictionary writeToFileAtPath:tempDictPath];

    BOOL success = [self loadPronunciationDictionaryFromFile:tempDictPath];

    if (success) {
        _dictionary = [dictionary copy];
    }

    [[NSFileManager defaultManager] removeItemAtPath:tempDictPath error:nil];

    return success;
}

- (BOOL)savePronunciationDictionaryToFile:(NSString*)path
{
    [self.dictionary writeToFileAtPath:path];

    return YES;
}

- (BOOL)addWord:(NSString*)word withPhones:(NSString*)phones update:(BOOL)update
{
    const char* cWord = [word cStringUsingEncoding:NSUTF8StringEncoding];
    const char* cPhones = [phones cStringUsingEncoding:NSUTF8StringEncoding];
    int cUpdate = FALSE;

    if (update) {
        cUpdate = TRUE;
    }

    int success = ps_add_word(self.decoder, cWord, cPhones, cUpdate);

    return success >= 0;
}

- (NSArray<NSString*>*)lookupWord:(NSString*)word
{
    return self.dictionary.entries[word];
}

#pragma mark - Searches
- (BOOL)setActiveSearchWithName:(NSString*)name
{
    const char* cName = [name cStringUsingEncoding:NSUTF8StringEncoding];
    int success = ps_set_search(self.decoder, cName);

    return success == 0;
}

- (BOOL)addSearch:(NTSpeechSearch*)search
{
    if ([self.internalSearches.allKeys containsObject:search.name]) {
        NSLog(@"Already search present with the name %@", search.name);
        return NO;
    }

    BOOL success = NO;

    if ([search isKindOfClass:[NTKeywordSpottingSearch class]]) {
        success = [self addKeywortSpottingSearch:(NTKeywordSpottingSearch*)search];
    }
    else if ([search isKindOfClass:[NTGrammarSearch class]]) {
        success = [self addGrammarSearch:(NTGrammarSearch*)search];
    }
    else if ([search isKindOfClass:[NTJsgfFileSearch class]]) {
        success = [self addJsgfFileSearch:(NTJsgfFileSearch*)search];
    }
    else if ([search isKindOfClass:[NTNGramFileSearch class]]) {
        success = [self addNGramFileSearch:(NTNGramFileSearch*)search];
    }

    if (success) {
        self.internalSearches[search.name] = search;
    }

    return success;
}

- (BOOL)addKeywortSpottingSearch:(NTKeywordSpottingSearch*)search
{
    NSString* tempKwsPath = [NTFileSystem getTempFilePath];
    [search saveToFileAtPath:tempKwsPath];

    const char* cName = [search.name cStringUsingEncoding:NSUTF8StringEncoding];
    const char* cPath = [tempKwsPath cStringUsingEncoding:NSUTF8StringEncoding];

    int success = ps_set_kws(self.decoder, cName, cPath);

    [[NSFileManager defaultManager] removeItemAtPath:tempKwsPath error:nil];

    return success == 0;
}

- (BOOL)addGrammarSearch:(NTGrammarSearch*)search
{
    NSString* jsgf = [NTJsgfGrammar serializeGrammar:search.grammar];
    const char* cJsgf = [jsgf cStringUsingEncoding:NSUTF8StringEncoding];
    const char* cName = [search.name cStringUsingEncoding:NSUTF8StringEncoding];

    int success = ps_set_jsgf_string(self.decoder, cName, cJsgf);

    return success == 0;
}

- (BOOL)addJsgfFileSearch:(NTJsgfFileSearch*)search
{
    const char* cPath = [search.path cStringUsingEncoding:NSUTF8StringEncoding];
    const char* cName = [search.name cStringUsingEncoding:NSUTF8StringEncoding];

    int success = ps_set_jsgf_file(self.decoder, cName, cPath);

    return success == 0;
}

- (BOOL)addNGramFileSearch:(NTNGramFileSearch*)search
{
    const char* cPath = [search.path cStringUsingEncoding:NSUTF8StringEncoding];
    const char* cName = [search.name cStringUsingEncoding:NSUTF8StringEncoding];

    int success = ps_set_lm_file(self.decoder, cName, cPath);

    return success == 0;
}

- (BOOL)removeSearchWithName:(NSString*)name
{
    const char* cName = [name cStringUsingEncoding:NSUTF8StringEncoding];
    int success = ps_unset_search(self.decoder, cName);

    if (success == 0) {
        [self.internalSearches removeObjectForKey:name];
    }

    return success == 0;
}

#pragma mark - Processing
- (BOOL)startUtterance
{
    return !ps_start_utt(self.decoder);
}

- (BOOL)endUtterance
{
    return !ps_end_utt(self.decoder);
}

- (BOOL)inSpeech
{
    return ps_get_in_speech(self.decoder);
}

- (int)processData:(int16_t*)data samples:(size_t)numberOfSamples
{
    return [self processData:data samples:numberOfSamples noSearch:NO fullUtterance:NO];
}

- (int)processData:(int16_t*)data samples:(size_t)numberOfSamples noSearch:(BOOL)noSearch fullUtterance:(BOOL)isFullUtterance
{
    int cNoSearch = 0;
    int cFullUtterance = 0;

    if (noSearch) {
        cNoSearch = 1;
    }

    if (isFullUtterance) {
        cFullUtterance = 1;
    }

    return ps_process_raw(self.decoder, data, numberOfSamples, cNoSearch, cFullUtterance);
}

#pragma mark - Hypotheses
- (NTHypothesis*)getHypothesis
{
    SInt32 psScore = 0;
    const char* cValue = ps_get_hyp(self.decoder, &psScore);

    if (cValue == NULL) {
        return nil;
    }

    NSString* value = [NSString stringWithCString:cValue encoding:NSUTF8StringEncoding];
    double score = pow(10.0, psScore);

    return [NTHypothesis hypothesis:value score:score];
}

- (NTHypothesis*)getHypothesisFinal:(BOOL*)isFinal
{
    //TODO: final??
    return nil;
}

@end
