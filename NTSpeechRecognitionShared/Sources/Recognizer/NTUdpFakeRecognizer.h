//
//  NTUdpFakeRecognizer.h
//  NTSpeechRecognition
//
//  Created by Matthias Büchi on 13/07/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import "NTSpeechRecognizer.h"

extern UInt16 const FAKE_RECOGNIZER_UDP_DEFAULT_PORT;

/*!
    A recognizer I used for testing and evaluation purposes. It just receives string from a udp connection and posts them as hypotheses.
 */
@interface NTUdpFakeRecognizer : NSObject <NTSpeechRecognizer>

- (instancetype)initWithPort:(UInt16)port;

- (instancetype)initWithAudioSource:(NTAudioSource*)audioSource port:(UInt16)port;

@end
