//
//  NTSpeechRecognizer.h
//  NTSpeechRecognizer
//
//  Created by Matthias Büchi on 21/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for NTSpeechRecognizer.
FOUNDATION_EXPORT double NTSpeechRecognizerVersionNumber;

//! Project version string for NTSpeechRecognizer.
FOUNDATION_EXPORT const unsigned char NTSpeechRecognizerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <NTSpeechRecognizer/PublicHeader.h>

// POCKETSPHINX
#import <NTSpeechRecognizer/NTPocketSphinxConfig.h>
#import <NTSpeechRecognizer/NTPocketSphinxDecoder.h>

// AUDIOSOURCE
#import <NTSpeechRecognizer/NTAudioSource.h>
#import <NTSpeechRecognizer/NTMicrophoneAudioSource.h>