//
//  RJGoogleTTS.h
//  iGod
//
//  Created by Rishabh Jain on 11/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*
Purpose of Class: This class is meant to be used to capitalize on the Google Translate Speech Services, by allowing a developer to use this as speech to text. This will eventually be ported to all different languages that Google supports!
*/

#import <Foundation/Foundation.h>
#import "SettingsViewController.h"

@class RJGoogleTTS;

@protocol RJGoogleTTSDelegate <NSObject>

@required
- (void)receivedAudio:(NSMutableData *)data;
- (void)sentAudioRequest;
- (void)handleFailedRequest;

@end

@interface RJGoogleTTS : NSObject {
//    id <RJGoogleTTSDelegate> delegate;
    id delegate;
    NSMutableData *downloadedData;
}

//@property (nonatomic, retain) id <RJGoogleTTSDelegate> delegate;
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) NSMutableData *downloadedData;

- (void)convertTextToSpeech:(NSString *)searchString;
- (void)convertTextToSpeech:(NSString *)thisString withVoiceType:(NSString *)thisVoiceType andThisSpeedType:(NSString *)thisSpeedType;
- (void)setDelegateToObject:(id)thisObject;

@end
