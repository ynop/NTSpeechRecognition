//
//  NTMicrophoneAudioSource.h
//  NTSpeechRecognition
//
//  Created by Matthias Büchi on 24/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import "NTAudioSource.h"
#import <AVFoundation/AVFoundation.h>

@interface NTMicrophoneAudioSource : NTAudioSource

@property (nonatomic, readonly) AudioStreamBasicDescription format;

- (instancetype)init;

- (instancetype)initWithFormat:(AudioStreamBasicDescription)format;

@end
