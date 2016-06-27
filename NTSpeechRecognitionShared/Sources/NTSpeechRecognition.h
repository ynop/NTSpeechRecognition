//
//  NTSpeechRecognition.h
//  NTSpeechRecognition
//
//  Created by Matthias Büchi on 21/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for NTSpeechRecognizer.
FOUNDATION_EXPORT double NTSpeechRecognitionVersionNumber;

//! Project version string for NTSpeechRecognizer.
FOUNDATION_EXPORT const unsigned char NTSpeechRecognitionVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <NTSpeechRecognition/PublicHeader.h>

// POCKETSPHINX
#import <NTSpeechRecognition/NTPocketSphinxConfig.h>
#import <NTSpeechRecognition/NTPocketSphinxDecoder.h>

// AUDIOSOURCE
#import <NTSpeechRecognition/NTAudioSource.h>
#import <NTSpeechRecognition/NTMicrophoneAudioSource.h>

// RECOGNIZER
#import <NTSpeechRecognition/NTPocketSphinxRecognizer.h>
#import <NTSpeechRecognition/NTSpeechRecognizer.h>