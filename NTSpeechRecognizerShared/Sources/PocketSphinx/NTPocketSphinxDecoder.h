//
//  NTPocketSphinxDecoder.h
//  NTSpeechRecognizer
//
//  Created by Matthias Büchi on 21/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NTSpeechTools/NTSpeechTools.h>

#import "NTPocketSphinxConfig.h"

@interface NTPocketSphinxDecoder : NSObject

@property (nonatomic, strong, readonly) NTPocketSphinxConfig* config;

@property (nonatomic, strong, readonly) NTPronunciationDictionary* dictionary;

@property (nonatomic, strong, readonly) NTSpeechSearch* activeSearch;

@property (nonatomic, strong, readonly) NSArray<NTSpeechSearch*>* searches;

- (instancetype)initWithConfiguration:(NTPocketSphinxConfig*)config;

#pragma mark - Configuration
/*!
 *  Reinitialize the decoder with updated configuration. This function allows you to switch the acoustic model, dictionary, or other configuration without creating an entirely new decoding object.
 *
 *  @param config Config
 *
 *  @return YES on succes, NO on failure
 */
- (BOOL)reinitWithConfiguration:(NTPocketSphinxConfig*)config;

#pragma mark - Pronounciation Dictionary
/*!
 *  Load the dictionary from a file
 *
 *  @param pronunciationDictPath Path to the dictionary file
 *
 *  @return YES on succes, NO on failure
 */
- (BOOL)loadPronunciationDictionaryFromFile:(NSString*)pronunciationDictPath;

/*!
 *  Load pronunciation and filler dictionary from files
 *
 *  @param pronunciationDictPath Path to pronunciation file
 *  @param fillerDictPath        Path to filler file
 *
 *  @return YES on succes, NO on failure
 */
- (BOOL)loadPronunciationDictionaryFromFile:(NSString*)pronunciationDictPath andFillerDictionary:(NSString*)fillerDictPath;

/*!
 *  Load pronunciation dictionary
 *
 *  @param dictionary Dictionary
 *
 *  @return YES on succes, NO on failure
 */
- (BOOL)loadPronunciationDictionary:(NTPronunciationDictionary*)dictionary;

/*!
 *  Save the dictionary to a file
 *
 *  @param path Path to write to
 *
 *  @return YES on succes, NO on failure
 */
- (BOOL)savePronunciationDictionaryToFile:(NSString*)path;

/*!
 *  Add word to the dictionary
 *
 *  @param word   Word
 *  @param phones Phonemes
 *  @param update If YES, update the search module (whichever one is currently active) to recognize the newly added word. If adding multiple words, it is more efficient to pass NO here in all but the last word.
 *
 *  @return YES on succes, NO on failure
 */
- (BOOL)addWord:(NSString*)word withPhones:(NSString*)phones update:(BOOL)update;

/*!
 *  Lookup a word
 *
 *  @param word Word
 *
 *  @return Array of phone strings or empty array if word not present.
 */
- (NSArray<NSString*>*)lookupWord:(NSString*)word;

#pragma mark - Searches
/*!
 *  Activates search with the provided name. The search must be added before.
 *
 *  @param name Name
 *
 *  @return YES on succes, NO on failure
 */
- (BOOL)setActiveSearchWithName:(NSString*)name;

/*!
 *  Adds new search. The search can be activated using @link -setActiveSearchWithName @/link
 *
 *  @param search search
 *
 *  @return Yes on succes, NO on failure
 */
- (BOOL)addSearch:(NTSpeechSearch*)search;

/*!
 *  Removes the search with the given name
 *
 *  @param name Name
 *
 *  @return Yes on succes, NO on failure
 */
- (BOOL)removeSearchWithName:(NSString*)name;

#pragma mark - Processing
/*!
 *  Start utterance processing.
 *
 *  This function should be called before any utterance data is passed to the decoder. It marks the start of a new utterance and reinitializes internal data structures.
 *
 *  @return YES on success, NO on error
 */
- (BOOL)startUtterance;

/*!
 *  End utterance processing.
 *
 *  @return YES on success, NO on error
 */
- (BOOL)endUtterance;

/*!
 *  Checks if the last feed audio buffer contained speech.
 *
 *  @return YES if last buffer contained speech, NO otherwise
 */
- (BOOL)inSpeech;

/*!
 *  Decode raw audio data.
 *
 *  @param data            Data
 *  @param numberOfSamples Number of Samples
 *
 *  @return Number of frames of data searched, or <0 for error.
 */
- (int)processData:(int16_t*)data samples:(size_t)numberOfSamples;

/*!
 *  Decode raw audio data.
 *
 *  @param data            Data
 *  @param numberOfSamples Number of Samples
 *  @param noSearch        If YES, perform feature extraction but don't do any recognition yet. This may be necessary if your processor has trouble doing recognition in real-time.
 *  @param isFullUtterance If YES, this block of data is a full utterance worth of data. This may allow the recognizer to produce more accurate results.
 *
 *  @return Number of frames of data searched, or <0 for error.
 */
- (int)processData:(int16_t*)data samples:(size_t)numberOfSamples noSearch:(BOOL)noSearch fullUtterance:(BOOL)isFullUtterance;

#pragma mark - Hypotheses
/*!
 *  Get hypothesis.
 *
 *  @return Best hypothesis at this point in decoding. Nil if no hyp is available.
 */
- (NTHypothesis*)getHypothesis;

/*!
 *  Get hypothesis final flag.
 *
 *  @param isFinal Flag which is set to YES if hypothesis is reached final state in the grammar.
 *
 *  @return Best hypothesis at this point in decoding. nil if no hypothesis is available.
 */
- (NTHypothesis*)getHypothesisFinal:(BOOL*)isFinal;

@end
