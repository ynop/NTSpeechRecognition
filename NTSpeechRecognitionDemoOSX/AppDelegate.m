//
//  AppDelegate.m
//  NTPocketSphinxDemoOSX
//
//  Created by Matthias Büchi on 21/06/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import "AppDelegate.h"

#import <NTSpeechRecognition/NTSpeechRecognition.h>

@interface AppDelegate () <NTAudioSourceDelegate>

@property (nonatomic, strong) NTPocketSphinxRecognizer* recognizer;
@property (nonatomic, strong) NTMicrophoneAudioSource* source;

@property (nonatomic, strong) NSMutableData* data;

@end

@implementation AppDelegate

- (void)audioSource:(NTAudioSource*)audioSource didReadData:(NSData*)data
{
    NSLog(@"DATA %lu", (unsigned long)data.length);

    [self.data appendData:data];
}

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
    self.data = [NSMutableData data];
    //NTPocketSphinxDecoder* decoder = [NTPocketSphinxDecoder new];

    self.source = [NTMicrophoneAudioSource new];
    self.recognizer = [[NTPocketSphinxRecognizer alloc] initWithAudioSource:self.source];

    [self.source addDelegate:self];

    [self.recognizer start];
    [self.source start];

    /*
     
     ps_decoder_t* ps;
     cmd_ln_t* config;
     FILE* fh;
     char const *hyp, *uttid;
     int16 buf[512];
     int rv;
     int32 score;
     
     NSString* basePath = [[NSBundle bundleForClass:self.class] resourcePath];
     
     const char* model = [[basePath stringByAppendingPathComponent:@"en-us"] cStringUsingEncoding:NSUTF8StringEncoding];
     const char* lm = [[basePath stringByAppendingPathComponent:@"en-us.lm.bin"] cStringUsingEncoding:NSUTF8StringEncoding];
     const char* dict = [[basePath stringByAppendingPathComponent:@"cmudict-en-us.dic"] cStringUsingEncoding:NSUTF8StringEncoding];
     const char* raw = [[basePath stringByAppendingPathComponent:@"numbers.raw"] cStringUsingEncoding:NSUTF8StringEncoding];
     
     config = cmd_ln_init(NULL, ps_args(), TRUE,
     "-hmm", model,
     "-lm", lm,
     "-dict", dict,
     NULL);
     
     if (config == NULL) {
     fprintf(stderr, "Failed to create config object, see log for details\n");
     }
     
     ps = ps_init(config);
     if (ps == NULL) {
     fprintf(stderr, "Failed to create recognizer, see log for details\n");
     }
     
     const char* searchname = ps_get_search(ps);
     
     printf("\n \n CURRENT SEARCH: %s \n\n", searchname);
     
     fh = fopen(raw, "rb");
     if (fh == NULL) {
     fprintf(stderr, "Unable to open input file goforward.raw\n");
     }
     
     rv = ps_start_utt(ps);
     
     while (!feof(fh)) {
     size_t nsamp;
     nsamp = fread(buf, 2, 512, fh);
     rv = ps_process_raw(ps, buf, nsamp, FALSE, FALSE);
     }
     
     rv = ps_end_utt(ps);
     hyp = ps_get_hyp(ps, &score);
     printf("Recognized: %s\n", hyp);
     
     fclose(fh);
     ps_free(ps);
     cmd_ln_free_r(config);*/

    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification*)aNotification
{
    // Insert code here to tear down your application

    [self.data writeToFile:@"/Users/matthi/Documents/test.wav" atomically:NO];
}

@end
