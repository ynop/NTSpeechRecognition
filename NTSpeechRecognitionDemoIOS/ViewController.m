//
//  ViewController.m
//  NTPocketSphinxDemoIOS
//
//  Created by Matthias Büchi on 21/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import "ViewController.h"
#import <NTSpeechRecognition/NTSpeechRecognition.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, NTSpeechRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIButton* startButton;
@property (weak, nonatomic) IBOutlet UIButton* suspendButton;
@property (weak, nonatomic) IBOutlet UILabel* statusLabel;
@property (weak, nonatomic) IBOutlet UISwitch* nullHypSwitch;
@property (weak, nonatomic) IBOutlet UITextView* hypField;
@property (weak, nonatomic) IBOutlet UITableView* searchesTable;

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
    
    [self.searchesTable reloadData];
    self.hypField.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startStop:(id)sender
{
    if (self.recognizer.isStarted) {
        [self.recognizer stop];
        [self.source stop];
        [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    }
    else {
        [self.recognizer start];
        [self.source start];
        [self.startButton setTitle:@"Stop" forState:UIControlStateNormal];
    }
}

- (IBAction)suspendResume:(id)sender
{
    if (self.recognizer.isSuspended) {
        [self.recognizer resume];
        [self.source resume];
        [self.startButton setTitle:@"Suspend" forState:UIControlStateNormal];
    }
    else {
        [self.recognizer suspend];
        [self.source resume];
        [self.startButton setTitle:@"Resume" forState:UIControlStateNormal];
    }
}

- (IBAction)setReturnNullHyps:(id)sender
{
    self.recognizer.returnNullHypotheses = self.nullHypSwitch.on;
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

        self.hypField.text = all;

    });
}

- (void)speechRecognizer:(id<NTSpeechRecognizer>)speechRecognizer didChangeListeningState:(BOOL)isListening
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.recognizer.isStarted) {
            if (self.recognizer.isSuspended) {
                self.statusLabel.text = @"Suspended";
            }
            else {
                self.statusLabel.text = @"Listening ...";
            }
        }
        else {
            self.statusLabel.text = @"Stopped";
        }

    });
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recognizer.searches.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = self.recognizer.searches[indexPath.row].name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.recognizer.searches.count) {
        NTSpeechSearch *search = self.recognizer.searches[indexPath.row];
        
        [self.recognizer setActiveSearchByName:search.name];
        
    }
}

@end
