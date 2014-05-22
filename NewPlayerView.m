//
//  NewPlayerView.m
//  satisfaction_survey
//
//  Created by David Horton on 11/4/12.
//
//

#import "NewPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation NewPlayerView

//for creating view programiticly

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

//from nib
-(id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		
	}
	
	return self;
}

+ (Class)layerClass
{
	
	return [AVPlayerLayer class];
	
}

- (AVPlayer*)player
{
	return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player
{
	[(AVPlayerLayer*)[self layer] setPlayer:player];
	
	[(AVPlayerLayer*)[self layer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)dealloc {
    [super dealloc];
}


@end