//
//  AMTallLayout.m
//  Amethyst
//
//  Created by Ian on 5/17/13.
//  Copyright (c) 2013 Ian Ynda-Hummel. All rights reserved.
//

#import "AMTallLayout.h"

#import "AMWindow.h"
#import "AMWindowManager.h"
#import "NSScreen+FrameAdjustment.h"

@interface AMTallLayout ()
// Ratio of screen width taken up by main pane
@property (nonatomic, assign) CGFloat mainPaneRatio;
// The number of windows that should be displayed in the main pane.
@property (nonatomic, assign) NSInteger mainPaneCount;
@end

@implementation AMTallLayout

#pragma mark Lifecycle

- (id)init {
    self = [super init];
    if (self) {
        self.mainPaneCount = 1;
        self.mainPaneRatio = 0.5;
    }
    return self;
}

#pragma mark AMLayout

- (void)reflowScreen:(NSScreen *)screen withWindows:(NSArray *)windows {
    if (windows.count == 0) return;

    NSUInteger mainPaneCount = MIN(windows.count, self.mainPaneCount);

    NSInteger secondaryPaneCount = windows.count - mainPaneCount;
    BOOL hasSecondaryPane = (secondaryPaneCount > 0);

    CGRect screenFrame = screen.adjustedFrame;

    CGFloat mainPaneWindowHeight = round(screenFrame.size.height / mainPaneCount);
    CGFloat secondaryPaneWindowHeight = (hasSecondaryPane ? round(screenFrame.size.height / secondaryPaneCount) : 0.0);

    CGFloat mainPaneWindowWidth = round(screenFrame.size.width * (hasSecondaryPane ? self.mainPaneRatio : 1));
    CGFloat secondaryPaneWindowWidth = screenFrame.size.width - mainPaneWindowWidth;

    AMWindow *focusedWindow = [AMWindow focusedWindow];

    for (NSUInteger windowIndex = 0; windowIndex < windows.count; ++windowIndex) {
        AMWindow *window = windows[windowIndex];
        CGRect windowFrame;

        if (windowIndex < mainPaneCount) {
            windowFrame.origin.x = screenFrame.origin.x;
            windowFrame.origin.y = screenFrame.origin.y + (mainPaneWindowHeight * windowIndex);
            windowFrame.size.width = mainPaneWindowWidth;
            windowFrame.size.height = mainPaneWindowHeight;
        } else {
            windowFrame.origin.x = screenFrame.origin.x + mainPaneWindowWidth;
            windowFrame.origin.y = screenFrame.origin.y + (secondaryPaneWindowHeight * (windowIndex - mainPaneCount));
            windowFrame.size.width = secondaryPaneWindowWidth;
            windowFrame.size.height = secondaryPaneWindowHeight;
        }

        window.frame = windowFrame;

        if ([window isEqual:focusedWindow]) {
            windowFrame = window.frame;
            if (!CGRectContainsRect(screenFrame, windowFrame)) {
                windowFrame.origin.x = MIN(windowFrame.origin.x, CGRectGetMaxX(screenFrame) - CGRectGetWidth(windowFrame));
                windowFrame.origin.y = MIN(windowFrame.origin.y, CGRectGetMaxY(screenFrame) - CGRectGetHeight(windowFrame));

                window.position = windowFrame.origin;
            }
        }
    }
}

- (void)expandMainPane {
    self.mainPaneRatio = MIN(1, self.mainPaneRatio + 0.05);
}

- (void)shrinkMainPane {
    self.mainPaneRatio = MAX(0, self.mainPaneRatio - 0.05);
}

- (void)increaseMainPaneCount {
    self.mainPaneCount = self.mainPaneCount + 1;
}

- (void)decreaseMainPaneCount {
    self.mainPaneCount = MAX(1, self.mainPaneCount - 1);
}

@end
