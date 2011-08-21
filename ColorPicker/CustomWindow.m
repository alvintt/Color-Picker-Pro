#import "CustomWindow.h"

@implementation CustomWindow

@synthesize attachPoint;

- (NSBezierPath *)backgroundPath
{
    return [NSBezierPath bezierPathWithRoundedRect:self.frame
                                     xRadius:5
                                     yRadius:5];
}


- (NSColor *)background
{
    NSImage *bg = [[NSImage alloc] initWithSize:[self frame].size];
    NSRect bgRect = NSZeroRect;
    bgRect.size = [bg size];
    
    [bg lockFocus];
    [NSGraphicsContext saveGraphicsState];
    
    NSBezierPath *path = [self backgroundPath];
    
    [path addClip];
    
    [path setLineWidth:3.0];
    
    [[NSColor darkGrayColor] setFill];
	[[NSColor blackColor] setStroke];
    
    [path fill];
    [path stroke];
    
    [NSGraphicsContext restoreGraphicsState];
    [bg unlockFocus];
    
    return [NSColor colorWithPatternImage:bg];
}

- (CustomWindow *)initWithView:(NSView *)view
{
    NSRect contentRect = NSZeroRect;
	contentRect.size = [view frame].size;
    	
	if ((self = [super initWithContentRect:contentRect
                                 styleMask:NSBorderlessWindowMask 
                                   backing:NSBackingStoreBuffered 
                                     defer:NO])) {
		
		[[self contentView] addSubview:view];
        
        [self setBackgroundColor:[self background]];
        [self setMovableByWindowBackground:YES];
        [self setExcludedFromWindowsMenu:YES];
        [self setOpaque:NO];
        [self setHasShadow:YES];
        [self setDelegate:self];
	}
	return self;
}

#pragma mark Util

- (void)setAttachPoint:(NSPoint)point {
    NSPoint origin;

    // remember positions
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsFrameOriginX]) {
        float x = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsFrameOriginX] floatValue];
        float y = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsFrameOriginY] floatValue];
        
        origin = NSMakePoint(x, y);
    } else
    {
        attachPoint = point;
        
        float windowRightEdge = point.x + ([self frame].size.width / 2);
        float screenRightEdge = [[NSScreen mainScreen] frame].size.width;
        if ((windowRightEdge - screenRightEdge) > 0) {
            point.x -= windowRightEdge - screenRightEdge + 10.0f; // 10.0f of margin
        }
        
        origin = NSZeroPoint;
        origin.x = point.x - ([self frame].size.width / 2);
        origin.y = point.y - [self frame].size.height;
    }
    
    [self setFrameOrigin:origin];

}


// This hides the window when the alpha is 0.0
- (void)setAlphaValue:(CGFloat)windowAlpha 
{
	[super setAlphaValue:windowAlpha];
	
    if (0.0f == windowAlpha)
    {
        [self orderOut:self];
    }
    else
    {
        [self makeKeyAndOrderFront:self];
        [NSApp activateIgnoringOtherApps:YES];

    }
}

- (void)windowDidResignKey:(NSNotification *)notification 
{
	[[self animator] setAlphaValue:0.0f];
}

- (BOOL)canBecomeKeyWindow {
	return YES;
}

- (void)toggleVisibility 
{
	if (![self isVisible]) 
    {
		[self setAlphaValue:0.0f];
		[[self animator] setAlphaValue:1.0f];
	}
	else {
		[[self animator] setAlphaValue:0.0f];
	}
}

#pragma mark events

- (void)windowDidMove:(NSNotification *)notification {
    float x = [[notification object] frame].origin.x;
    float y = [[notification object] frame].origin.y;

    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:x] forKey:kUserDefaultsFrameOriginX];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:y] forKey:kUserDefaultsFrameOriginY];
    
}

@end