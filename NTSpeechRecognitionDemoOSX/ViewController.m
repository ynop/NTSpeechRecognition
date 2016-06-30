//
//  ViewController.m
//  NTPocketSphinxDemoOSX
//
//  Created by Matthias Büchi on 21/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import "ViewController.h"
#import <NTSpeechRecognition/NTSpeechRecognition.h>

@interface ViewController () <NTSpeechRecognizerDelegate>

@property (weak) IBOutlet NSButtonCell* startButton;
@property (weak) IBOutlet NSButton* suspendButton;
@property (weak) IBOutlet NSTextField* statusLabel;
@property (unsafe_unretained) IBOutlet NSTextView* hypothesesArea;
@property (weak) IBOutlet NSButton* returnNullHypsCheckBox;

@property (nonatomic, strong) NTPocketSphinxRecognizer* recognizer;
@property (nonatomic, strong) NTMicrophoneAudioSource* source;

@property (nonatomic, strong) NTJsgfFileSearch* numbersSearch;
@property (nonatomic, strong) NTJsgfFileSearch* dateSearch;
@property (nonatomic, strong) NTJsgfFileSearch* yesNoSearch;
@property (nonatomic, strong) NTJsgfFileSearch* icaoSearch;

@property (nonatomic, strong) NTNGramFileSearch* controlSearch;

@property (nonatomic, strong) NTPronunciationDictionary* dictionary;

@property (nonatomic, strong) NSMutableArray* lastHyps;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.

    self.lastHyps = [NSMutableArray array];

    self.source = [NTMicrophoneAudioSource new];

    // CREATE RECOGNIZER WITH AUDIO SOURCE
    self.recognizer = [[NTPocketSphinxRecognizer alloc] initWithAudioSource:self.source];
    [self.recognizer addDelegate:self];

    // CREATE SEARCH
    self.numbersSearch = [NTJsgfFileSearch searchWithName:@"Numbers" path:[[NSBundle mainBundle] pathForResource:@"numbers" ofType:@".jsgf"]];
    self.dateSearch = [NTJsgfFileSearch searchWithName:@"Date" path:[[NSBundle mainBundle] pathForResource:@"date" ofType:@".jsgf"]];
    self.yesNoSearch = [NTJsgfFileSearch searchWithName:@"Yes_No" path:[[NSBundle mainBundle] pathForResource:@"yes_no" ofType:@".jsgf"]];
    self.icaoSearch = [NTJsgfFileSearch searchWithName:@"ICAO" path:[[NSBundle mainBundle] pathForResource:@"icao_single" ofType:@".jsgf"]];
    self.controlSearch = [NTNGramFileSearch searchWithName:@"Control" path:[[NSBundle mainBundle] pathForResource:@"control" ofType:@".lm"]];

    // CREATE DICTIONARY
    self.dictionary = [[NTPronunciationDictionary alloc] initWithName:@"Default"];
    [self.dictionary loadWordsFromFileAtPath:[[NSBundle mainBundle] pathForResource:@"numbers" ofType:@".dic"]];
    [self.dictionary loadWordsFromFileAtPath:[[NSBundle mainBundle] pathForResource:@"date" ofType:@".dic"]];
    [self.dictionary loadWordsFromFileAtPath:[[NSBundle mainBundle] pathForResource:@"yes_no" ofType:@".dic"]];
    [self.dictionary loadWordsFromFileAtPath:[[NSBundle mainBundle] pathForResource:@"icao_single" ofType:@".dic"]];
    [self.dictionary loadWordsFromFileAtPath:[[NSBundle mainBundle] pathForResource:@"control" ofType:@".dic"]];

    // ADD DICTIONARY AND SEARCH
    [self.recognizer loadPronunciationDictioanry:self.dictionary];
    [self.recognizer addSearch:self.numbersSearch];
    [self.recognizer addSearch:self.dateSearch];
    [self.recognizer addSearch:self.yesNoSearch];
    [self.recognizer addSearch:self.icaoSearch];
    [self.recognizer addSearch:self.controlSearch];
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)start:(id)sender
{
    if (self.recognizer.isStarted) {
        [self.recognizer stop];
        [self.source stop];
        self.startButton.title = @"Start";
    }
    else {
        [self.recognizer start];
        [self.source start];
        self.startButton.title = @"Stop";
    }
}

- (IBAction)suspend:(id)sender
{
    if (self.recognizer.isSuspended) {
        [self.recognizer resume];
        [self.source resume];
        self.suspendButton.title = @"Suspend";
    }
    else {
        [self.recognizer suspend];
        [self.source resume];
        self.suspendButton.title = @"Resume";
    }
}

- (IBAction)setGrammarNumbers:(id)sender
{
    [self.recognizer setActiveSearchByName:self.numbersSearch.name];
}

- (IBAction)setGrammarDate:(id)sender
{
    [self.recognizer setActiveSearchByName:self.dateSearch.name];
}

- (IBAction)setGrammarYesNo:(id)sender
{
    [self.recognizer setActiveSearchByName:self.yesNoSearch.name];
}

- (IBAction)setGrammarIcao:(id)sender
{
    [self.recognizer setActiveSearchByName:self.icaoSearch.name];
}

- (IBAction)setLmControl:(id)sender
{
    [self.recognizer setActiveSearchByName:self.controlSearch.name];
}

- (IBAction)setReturnNullHypotheses:(id)sender
{
    self.recognizer.returnNullHypotheses = (self.returnNullHypsCheckBox.state == NSOnState);
}

#pragma mark - Speech Recognizer Delegate
- (void)speechRecognizer:(id<NTSpeechRecognizer>)speechRecognizer didReceiveHypothesis:(NTHypothesis*)hypothesis forSearch:(NTSpeechSearch*)search
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.lastHyps.count >= 20) {
            [self.lastHyps removeObjectAtIndex:0];
        }

        [self.lastHyps addObject:[NSString stringWithFormat:@"%@ (%f)", hypothesis.value, hypothesis.posteriorProbability]];

        NSString* all = @"";

        for (NSString* hyp in self.lastHyps) {
            all = [all stringByAppendingFormat:@"%@\n", hyp];
        }

        self.hypothesesArea.string = all;

    });
}

- (void)speechRecognizer:(id<NTSpeechRecognizer>)speechRecognizer didChangeListeningState:(BOOL)isListening
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.recognizer.isStarted) {
            if (self.recognizer.isSuspended) {
                self.statusLabel.stringValue = @"Suspended";
            }
            else {
                self.statusLabel.stringValue = @"Listening ...";
            }
        }
        else {
            self.statusLabel.stringValue = @"Stopped";
        }

    });
}

@end
