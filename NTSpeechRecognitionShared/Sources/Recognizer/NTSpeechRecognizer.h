//
//  NTSpeechRecognizer.h
//  NTSpeechRecognition
//
//  Created by Matthias Büchi on 27/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NTSpeechTools/NTSpeechTools.h>

#import "NTAudioSource.h"

@protocol NTSpeechRecognizer;

/*!
 *  Delegate used to notify on state changes and received hypotheses.
 */
@protocol NTSpeechRecognizerDelegate <NSObject>

@optional

/*!
 *  Is called if the listening state of the recognizer changes.
 *
 *  @param speechRecognizer The recognizer that triggered the event.
 *  @param isListening      The listening state of the recognizer.
 */
- (void)speechRecognizer:(id<NTSpeechRecognizer>)speechRecognizer didChangeListeningState:(BOOL)isListening;

/*!
 *  Is called when recognizer detected the end of utterance and received a hypothesis.
 *
 *  @param speechRecognizer The recognizer that found the hyp.
 *  @param hypothesis       The found hypothesis.
 *  @param search           The search which was active when the hyp was recognized.
 */
- (void)speechRecognizer:(id<NTSpeechRecognizer>)speechRecognizer didReceiveHypothesis:(NTHypothesis*)hypothesis forSearch:(NTSpeechSearch*)search;

/*!
 *  Is called when recognizer found speech and received a hypothesis.
 *
 *  @param speechRecognizer The recognizer that found the hyp.
 *  @param hypothesis       The found hypothesis.
 *  @param search           The search which was active when the hyp was recognized.
 */
- (void)speechRecognizer:(id<NTSpeechRecognizer>)speechRecognizer didReceivePartialHypothesis:(NTHypothesis*)hypothesis forSearch:(NTSpeechSearch*)search;

@end

/*!
 *  Basic interface of a speech recognizer.
 */
@protocol NTSpeechRecognizer <NTAudioSourceDelegate>

/*!
 *  Current listening state. YES if the recognizer currently is listening for speech. Otherwise NO.
 *
 *  Same as (isStarted && !isSuspended).
 */
@property (nonatomic, readonly) BOOL isListening;

/*!
 *  YES if the recognizer was started.
 */
@property (nonatomic, readonly) BOOL isStarted;

/*!
 *  YES if the recognizer currently is suspended.
 */
@property (nonatomic, readonly) BOOL isSuspended;

/*!
 *  The dictionary of the recognizer.
 */
@property (nonatomic, strong, readonly) NTPronunciationDictionary* dictionary;

/*!
 *  All searches that are registered in this recognizer.
 */
@property (nonatomic, strong, readonly) NSArray<NTSpeechSearch*>* searches;

/*!
 *  The search currently is active.
 */
@property (nonatomic, strong, readonly) NTSpeechSearch* activeSearch;

/*!
 *  The audio source where the recognizer gets input data from.
 */
@property (nonatomic, strong) NTAudioSource* audioSource;

/*!
 *  Whether the recognizer should notify about NULL Hypotheses.
 */
@property (nonatomic) BOOL returnNullHypotheses;

/*!
 *  If enabled the recognizer returns partial hypotheses (Hyoptheses, when the end of the utterance wasn't detected)
 */
@property (nonatomic) BOOL returnPartialHypotheses;

#pragma mark - Init
/*!
 *  Creates a new recognizer with a given audio source.
 *
 *  @param audioSource Audio Source
 *
 *  @return instance
 */
- (instancetype)initWithAudioSource:(NTAudioSource*)audioSource;

#pragma mark - State
/*!
 *  Start the recognition process.
 */
- (void)start;

/*!
 *  Stop the recognition process. Has no effect if the process wasn't started.
 */
- (void)stop;

/*!
 *  Suspend the recognition process. Has no effect if the process wasn't started.
 */
- (void)suspend;

/*!
 *  Resume the recognition process. Has no effect if the process wasn't started or wasn't suspended.
 */
- (void)resume;

#pragma mark - Dictionary
/*!
 *  Loads the given dictionary.
 *
 *  @param dictionary Dictionary
 *
 *  @return YES on succes, NO on failure
 */
- (BOOL)loadPronunciationDictioanry:(NTPronunciationDictionary*)dictionary;

/*!
 *  Add the phones for the given word. Existing phones for the same words won't be deleted.
 *
 *  @attention Use addWords:(NSDictionary*)words when adding multiple words. So the recognizer doesn't has to update for every single word.
 *
 *  @param word   Word (e.g. "Flight")
 *  @param phones Phones (e.g. "F L AY T")
 *  @return YES on success
 */
- (BOOL)addWord:(NSString*)word phones:(NSString*)phones;

/*!
 *  Add multiple phones for the given word. Existing phones for the same words won't be deleted.
 *
 *  @attention Use addWords:(NSDictionary*)words when adding multiple words. So the recognizer doesn't has to update for every single word.
 *
 *  @param word         Word (e.g. "Flight")
 *  @param listOfPhones Array (e.g. ["F L AY T", "F L EY T"])
 *  @return YES on success
 */
- (BOOL)addWord:(NSString*)word listOfPhones:(NSArray*)listOfPhones;

/*!
 *  Adds words and phones from dictionary.
 *
 *  NSDictionary Format:
 *
 *  @{
 *    @"word" : @[ @"phone a", @"phone b", @"phone c"],
 *    @"word b" : @[ @"phone ba", @"phone bb",]
 *  }
 *
 *  @param words dictionary
 *  @return YES on success
 */
- (BOOL)addWords:(NSDictionary*)words;

#pragma mark - Searches
/*!
 *  Adds the given search to the recognizer. If there already is a search with the given name it will be replaced.
 *
 *  @param search Search
 *  @return YES on success, NO on failure
 */
- (BOOL)addSearch:(NTSpeechSearch*)search;

/*!
 *  Removes the given search.
 *
 *  @param search Search
 */
- (void)removeSearch:(NTSpeechSearch*)search;

/*!
 *  Removes the search with the given name if existing.
 *
 *  @param name Name of the search.
 */
- (void)removeSearchByName:(NSString*)name;

/*!
 *  Activates the search with the given name if existing.
 *
 *  @param name Name of the search.
 *
 *  @return YES if a search is existing with given name, otherwise NO.
 */
- (BOOL)setActiveSearchByName:(NSString*)name;

/*!
 *  Get the search with the given name, if existing.
 *
 *  @param name Name to search for.
 *
 *  @return Search if existing, otherwise nil.
 */
- (NTSpeechSearch*)searchWithName:(NSString*)name;

#pragma mark - Delegates
/*!
 *  Adds a delegate
 *
 *  @param delegate delegate
 */
- (void)addDelegate:(id<NTSpeechRecognizerDelegate>)delegate;

/*!
 *  Removes a delegate
 *
 *  @param delegate delegate
 */
- (void)removeDelegate:(id<NTSpeechRecognizerDelegate>)delegate;

@end
