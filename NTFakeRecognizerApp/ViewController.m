//
//  ViewController.m
//  NTFakeRecognizerApp
//
//  Created by Matthias Büchi on 13/07/16.
//  Copyright © 2016 ZHAW Institute of Applied Information Technology. All rights reserved.
//

#import "ViewController.h"
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>

@interface ViewController () <GCDAsyncUdpSocketDelegate>

@property (weak) IBOutlet NSTextField* ipField;
@property (weak) IBOutlet NSTextField* portField;

@property (weak) IBOutlet NSTextField* hypField;
@property (weak) IBOutlet NSButton* sendButton;

@property (weak) IBOutlet NSScrollView* recentTableView;

@property (nonatomic, strong) GCDAsyncUdpSocket* socket;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)sendHypothesis:(NSString*)hyp
{
    NSData* data = [hyp dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket sendData:data toHost:self.ipField.stringValue port:self.portField.intValue withTimeout:-1 tag:1];
}

- (IBAction)send:(id)sender
{
    [self sendHypothesis:self.hypField.stringValue];
}

- (IBAction)portEdited:(id)sender
{
}

- (IBAction)ipEdited:(id)sender
{
}

- (IBAction)suspend:(id)sender
{
    [self sendHypothesis:@"__SUSPEND__"];
}

- (IBAction)resume:(id)sender
{
    [self sendHypothesis:@"__RESUME__"];
}

@end