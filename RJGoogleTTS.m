//
//  RJGoogleTTS.m
//  iGod
//
//  Created by Rishabh Jain on 11/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RJGoogleTTS.h"

@implementation RJGoogleTTS
@synthesize downloadedData;
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setDelegateToObject:(id)thisObject {
    delegate = thisObject;
}

- (void)convertTextToSpeech:(NSString *)searchString {
    
    NSString *defaultVoice = @"usenglishfemale";
    int defaultSpeedNum = 0;

    
//    NSString *search = [NSString stringWithFormat:@"http://translate.google.com/translate_tts?tl=en&q=%@", searchString];
    NSString *search = [NSString stringWithFormat:@"http://www.ispeech.org/p/generic/getaudio?text=%@%%2C&voice=%@&speed=%d&action=convert", searchString, defaultVoice, defaultSpeedNum];
    
    // Example url (us english female voice playing at slow speed = -7:
    //http://www.ispeech.org/p/generic/getaudio?text=Welcome%20to%20the%20VA%20Palo%20Alto%20Healthcare%20System%2C&voice=usenglishfemale&speed=-7&action=convert
    
    search = [search stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    search = [search stringByReplacingOccurrencesOfString:@"\n" withString:@"%20"];
    NSLog(@"Search: %@", search);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:search]];
    [request setValue:@"Mozilla/5.0" forHTTPHeaderField:@"User-Agent"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [delegate sentAudioRequest];
    downloadedData = [[NSMutableData alloc] initWithLength:0];
}

- (void)convertTextToSpeech:(NSString *)thisString withVoiceType:(NSString *)thisVoiceType andThisSpeedType:(NSString *)thisSpeedType; {
    
    NSString *maleVoiceTypeString = @"usenglishmale";
    NSString *femaleVoiceTypeString = @"usenglishfemale";
    
    NSString *slowSpeedString = @"slowspeed";
    NSString *normalSpeedString = @"normalspeed";
    NSString *fastSpeedString = @"fastspeed";

    NSString *currentVoiceString = nil;

    int currentSpeedNum = 0;

    if ([thisVoiceType isEqualToString:maleVoiceTypeString]) {
        currentVoiceString = maleVoiceTypeString;
    } else if ([thisVoiceType isEqualToString:femaleVoiceTypeString]) {
        currentVoiceString = femaleVoiceTypeString;
    } else {
        currentVoiceString = femaleVoiceTypeString;
    }
    
    if ([thisSpeedType isEqualToString:slowSpeedString]) {
        currentSpeedNum = -3;
    } else if ([thisVoiceType isEqualToString:normalSpeedString]) {
        currentSpeedNum = 0;
    } else if ([thisVoiceType isEqualToString:fastSpeedString]) {
        currentSpeedNum = 4;
    } else {
        currentSpeedNum = 0;
    }
    
    //    NSString *search = [NSString stringWithFormat:@"http://translate.google.com/translate_tts?tl=en&q=%@", searchString];
    NSString *search = [NSString stringWithFormat:@"http://www.ispeech.org/p/generic/getaudio?text=%@%%2C&voice=%@&speed=%d&action=convert", thisString, currentVoiceString, currentSpeedNum];
    
    // Example url (us english female voice playing at slow speed = -7:
    //http://www.ispeech.org/p/generic/getaudio?text=Welcome%20to%20the%20VA%20Palo%20Alto%20Healthcare%20System%2C&voice=usenglishfemale&speed=-7&action=convert
    
    search = [search stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSLog(@"Search: %@", search);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:search]];
    [request setValue:@"Mozilla/5.0" forHTTPHeaderField:@"User-Agent"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [delegate sentAudioRequest];
    downloadedData = [[NSMutableData alloc] initWithLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[self.downloadedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.downloadedData appendData:data];
//    NSLog(@"===== GREAT SUCCESS! =======");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Failure");
    [delegate handleFailedRequest];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [delegate receivedAudio:self.downloadedData];
}

@end
