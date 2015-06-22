/*
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalTileView.h"
#import "KalDate.h"
#import "KalPrivate.h"
#import "KalGridView.h"

@implementation KalTileView

@synthesize date;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        origin = frame.origin;
        [self setIsAccessibilityElement:YES];
        [self setAccessibilityTraits:UIAccessibilityTraitButton];
        [self resetState];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGSize tileSize = [KalGridView tileSize];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    UIColor *textColor = nil;
    CGContextSelectFont(ctx, [font.fontName cStringUsingEncoding:NSUTF8StringEncoding], font.pointSize, kCGEncodingMacRoman);
    CGContextTranslateCTM(ctx, 0, tileSize.height);
    CGContextScaleCTM(ctx, 1, -1);
    
    if ([self isToday] && self.selected) {
        [self.tintColor setFill];
        UIRectFill(rect);
        textColor = [UIColor whiteColor];
    } else if ([self isToday] && !self.selected) {
        textColor = self.tintColor;
    } else if (self.selected) {
        [self.tintColor setFill];
        UIRectFill(rect);
        textColor = [UIColor whiteColor];
    } else if (self.belongsToAdjacentMonth) {
        textColor = [UIColor lightGrayColor];
    } else {
        textColor = [UIColor blackColor];
    }
    
    if (flags.marked) {
        CGContextAddEllipseInRect(ctx, CGRectMake((rect.size.width / 2) - 2.5, (rect.origin.y + rect.size.height / 5) - 2.5, 5, 5));
        CGContextSetFillColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
        CGContextEOFillPath(ctx);
    }
    
    NSUInteger n = [self.date day];
    NSString *dayText = [NSString stringWithFormat:@"%lu", (unsigned long)n];
    const char *day = [dayText cStringUsingEncoding:NSUTF8StringEncoding];
    CGSize textSize = [dayText sizeWithFont:font];
    CGFloat textX, textY;
    textX = roundf((tileSize.width / 2) - (textSize.width / 2));
    textY = 6.f + roundf(0.5f * (tileSize.height - textSize.height));
    [textColor setFill];
    CGContextShowTextAtPoint(ctx, textX, textY, day, n >= 10 ? 2 : 1);
}

- (void)resetState
{
    // realign to the grid
    CGRect frame = self.frame;
    frame.origin = origin;
    frame.size = [KalGridView tileSize];
    self.frame = frame;
    
    date = nil;
    flags.type = KalTileTypeRegular;
    flags.highlighted = NO;
    flags.selected = NO;
    flags.marked = NO;
}

- (void)setDate:(KalDate *)aDate
{
    if (date == aDate)
        return;
    
    date = aDate;
    
    [self setNeedsDisplay];
}

- (BOOL)isSelected { return flags.selected; }

- (void)setSelected:(BOOL)selected
{
    if (flags.selected == selected)
        return;
    
    // workaround since I cannot draw outside of the frame in drawRect:
    if (![self isToday]) {
        CGRect rect = self.frame;
        if (selected) {
            rect.origin.x--;
            rect.size.width++;
            rect.size.height++;
        } else {
            rect.origin.x++;
            rect.size.width--;
            rect.size.height--;
        }
        self.frame = rect;
    }
    
    flags.selected = selected;
    [self setNeedsDisplay];
}

- (BOOL)isHighlighted { return flags.highlighted; }

- (void)setHighlighted:(BOOL)highlighted
{
    if (flags.highlighted == highlighted)
        return;
    
    flags.highlighted = highlighted;
    [self setNeedsDisplay];
}

- (BOOL)isMarked { return flags.marked; }

- (void)setMarked:(BOOL)marked
{
    if (flags.marked == marked)
        return;
    
    flags.marked = marked;
    [self setNeedsDisplay];
}

- (KalTileType)type { return flags.type; }

- (void)setType:(KalTileType)tileType
{
    if (flags.type == tileType)
        return;
    
    // workaround since I cannot draw outside of the frame in drawRect:
    CGRect rect = self.frame;
    if (tileType == KalTileTypeToday) {
        rect.origin.x--;
        rect.size.width++;
        rect.size.height++;
    } else if (flags.type == KalTileTypeToday) {
        rect.origin.x++;
        rect.size.width--;
        rect.size.height--;
    }
    self.frame = rect;
    
    flags.type = tileType;
    [self setNeedsDisplay];
}

- (BOOL)isToday { return flags.type == KalTileTypeToday; }

- (BOOL)belongsToAdjacentMonth { return flags.type == KalTileTypeAdjacent; }


@end
