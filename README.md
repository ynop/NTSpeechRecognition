# NTSpeechRecognition
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)   


NTSpeechRecognition is a iOS/macOS framework, written in Objective-c, providing speech recognition functionality. For decoding [PocketSphinx](http://cmusphinx.sourceforge.net) is used. 

## Features
* Wrapper for the PocketSphinx decoder
* Recognizer based on the PocketSphinx decoder
  * Switch between searches immediatly
  * Partial hypotheses (Before end of utterance is detected)
  * Keyword Spotting, Grammar, NGram
* Fake Recognizer
  * Receive hypetheses from UDP connection
  * Can be used to test apps (Define exactly which hypothesis should show up)

## Installation

### Carthage
You can use carthage to install NTSpeechRecognition by adding to following to your Cartfile:

```
github "ynop/NTSpeechRecognition"
```

### Manual
You also can add this project as subproject.

## Documentation
Checkout out [API Reference](https://ynop.github.io/NTSpeechRecognition/).

## Basic Usage

### Setup Recognizer
At first the recognizer needs to be setup. For this purpose create an audio source, where the recognizer gets data from. Then we need to create the pronunciation dictionary and one or more searches (Check out [NTSpeechTools](https://github.com/ynop/NTSpeechTools).

```objc
  // Create an audio source
  NTMicrophoneAudioSource source = [NTMicrophoneAudioSource new];

  // CREATE RECOGNIZER WITH AUDIO SOURCE
  NTPocketSphinxRecognizer *recognizer = [[NTPocketSphinxRecognizer alloc] initWithAudioSource:source];
  [recognizer addDelegate:self];

  // CREATE SEARCHES
  NTSpeechSearch *numbersSearch = [NTJsgfFileSearch searchWithName:@"Numbers" path:@"path/to/numbergrammar"];
  NTSpeechSearch *dateSearch = [NTJsgfFileSearch searchWithName:@"Date" path:@"path/to/dategrammar"];
  
  // CREATE DICTIONARY
  NTPronunciationDictionary *dictionary = [[NTPronunciationDictionary alloc] initWithName:@"Default"];
  [dictionary loadWordsFromFileAtPath:@"path/to/number/dict"];
  [dictionary loadWordsFromFileAtPath:@"path/to/date/dict"];

  // ADD DICTIONARY AND SEARCH
  [recognizer loadPronunciationDictioanry:dictionary];
  [recognizer addSearch:numbersSearch];
  [recognizer addSearch:dateSearch];
```

### Handle start/suspend/resume/stop
Now we can control the recognizer. 

```objc
// Start recognizer and audiosource
[recognizer start];
[source start];

// Activate Searches
[recognizer setActiveSearchByName:@"Numbers"];

// Use suspend/resume for pausing
[recognizer suspend];
[recognizer resume];

// Stop
[recognizer stop];
[source stop];
```

### Listen for hypotheses
To get informed about hypotheses and state changes we implement the **NTSpeechRecognizerDelegate** methods.

```objc
// Receive Hypotheses
- (void)speechRecognizer:(id<NTSpeechRecognizer>)speechRecognizer didReceiveHypothesis:(NTHypothesis*)hypothesis forSearch:(NTSpeechSearch*)search
{
}

// Receive partial hypotheses (End of utterance wasn't detected yet)
// First you need to set returnPartialHypotheses = YES; 
- (void)speechRecognizer:(id<NTSpeechRecognizer>)speechRecognizer didReceivePartialHypothesis:(NTHypothesis*)hypothesis forSearch:(NTSpeechSearch*)search
{
}

// Receive information about state changes of the recognizer (listening/not listening)
- (void)speechRecognizer:(id<NTSpeechRecognizer>)speechRecognizer didChangeListeningState:(BOOL)isListening
{
}
```
