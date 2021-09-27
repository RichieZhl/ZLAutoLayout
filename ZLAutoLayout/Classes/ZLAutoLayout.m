//
//  ZLAutoLayout.m
//  ZLAutoLayout
//
//  Created by lylaut on 2021/9/26.
//

#import "ZLAutoLayout.h"
#import <objc/runtime.h>

@interface ZLConstraint () {
    __weak UIView *item1;
    NSLayoutAttribute attribute1;
    __weak UIView *item2;
    NSLayoutAttribute attribute2;
    NSLayoutRelation relation;
    CGFloat multiplier;
    CGFloat constant;
    BOOL safeAreaAttribute;
    
    UIView *installedView;
    NSLayoutConstraint *layoutConstraint;
}

- (instancetype)initWithItem:(UIView *)view attribute:(NSLayoutAttribute)attribute;

@end

@implementation ZLConstraint

- (instancetype)initWithItem:(UIView *)view attribute:(NSLayoutAttribute)attribute {
    if (self = [super init]) {
        item1 = view;
        attribute1 = attribute;
        item2 = nil;
        attribute2 = NSLayoutAttributeNotAnAttribute;
        multiplier = 1.0;
        constant = 0;
        safeAreaAttribute = NO;
        layoutConstraint = nil;
    }
    
    return self;
}

- (ZLConstraint * (^)(id item))equalTo {
    return ^(id item) {
        if ([item isKindOfClass:[ZLConstraint class]]) {
            ZLConstraint *c = (ZLConstraint *)item;
            self->item2 = c->item1;
            self->attribute2 = c->attribute1;
        } else if ([item isKindOfClass:[UIView class]]) {
            self->item2 = (UIView *)item;
        } else if ([item isKindOfClass:[NSNumber class]]) {
            self->constant = [(NSNumber *)item doubleValue];
        } else {
            return self;
        }
        self->relation = NSLayoutRelationEqual;
        return self;
    };
}

- (ZLConstraint * (^)(CGFloat m))multiplier {
    return ^(CGFloat m) {
        self->multiplier = m;
        return self;
    };
}

- (ZLConstraint * (^)(CGFloat c))constant {
    return ^(CGFloat c) {
        self->constant = c;
        if (self->layoutConstraint) {
            self->layoutConstraint.constant = self->constant;
        }
        return self;
    };
}

- (ZLConstraint * (^)(BOOL safeArea))withSafeArea {
    return ^(BOOL safeArea) {
        self->safeAreaAttribute = safeArea;
        return self;
    };
}

#pragma mark - heirachy

- (UIView *)closestCommonSuperview:(UIView *)view1 view2:(UIView *)view2 {
    UIView *closestCommonSuperview = nil;

    UIView *secondViewSuperview = view2.superview;
    while (!closestCommonSuperview && secondViewSuperview) {
        UIView *firstViewSuperview = view1.superview;
        while (!closestCommonSuperview && firstViewSuperview) {
            if (secondViewSuperview == firstViewSuperview) {
                closestCommonSuperview = secondViewSuperview;
            }
            firstViewSuperview = firstViewSuperview.superview;
        }
        secondViewSuperview = secondViewSuperview.superview;
    }
    return closestCommonSuperview == nil ? view1.superview : closestCommonSuperview;
}

- (ZLConstraint * (^)(void))install {
    return ^() {
        if (self->layoutConstraint) {
            [self->layoutConstraint setActive:YES];
            return self;
        }
        self->item1.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint *constraint = nil;
        
#define NormalAttr(attr) \
if (self->attribute1 == attr) { \
    if (self->attribute2 == NSLayoutAttributeNotAnAttribute) { \
        self->attribute2 = attr; \
    } \
      \
    if (@available(iOS 11.0, *)) { \
        if (self->safeAreaAttribute) { \
            constraint = [NSLayoutConstraint constraintWithItem:self->item1.safeAreaLayoutGuide  attribute:attr relatedBy:self->relation toItem:self->item2.safeAreaLayoutGuide attribute:self->attribute2  multiplier:self->multiplier constant:self->constant]; \
        } else { \
            constraint = [NSLayoutConstraint constraintWithItem:self->item1  attribute:attr relatedBy:self->relation toItem:self->item2 attribute:self->attribute2  multiplier:self->multiplier constant:self->constant]; \
        } \
    } else { \
        constraint = [NSLayoutConstraint constraintWithItem:self->item1  attribute:attr relatedBy:self->relation toItem:self->item2 attribute:self->attribute2  multiplier:self->multiplier constant:self->constant]; \
    } \
      \
    [constraint setActive:YES]; \
    self->layoutConstraint = constraint; \
    UIView *superView = [self closestCommonSuperview:self->item1 view2:self->item2]; \
    self->installedView = superView; \
    [superView addConstraint:constraint]; \
}
        
#define WHAttr(attr) \
if (self->attribute1 == attr) { \
    if (self->attribute2 == NSLayoutAttributeNotAnAttribute) { \
        self->attribute2 = attr; \
    } \
    constraint = [NSLayoutConstraint constraintWithItem:self->item1 attribute:attr relatedBy:self->relation toItem:self->item2 attribute:self->attribute2 multiplier:self->multiplier constant:self->constant]; \
    [constraint setActive:YES]; \
    self->layoutConstraint = constraint; \
    self->installedView = self->item1.superview; \
    [self->item1.superview addConstraint:constraint]; \
}
        
        NormalAttr(NSLayoutAttributeLeft)
        NormalAttr(NSLayoutAttributeTop)
        NormalAttr(NSLayoutAttributeRight)
        NormalAttr(NSLayoutAttributeBottom)
        NormalAttr(NSLayoutAttributeLeading)
        NormalAttr(NSLayoutAttributeTrailing)
        NormalAttr(NSLayoutAttributeCenterX)
        NormalAttr(NSLayoutAttributeCenterY)
        
        NormalAttr(NSLayoutAttributeLeftMargin)
        NormalAttr(NSLayoutAttributeTopMargin)
        NormalAttr(NSLayoutAttributeRightMargin)
        NormalAttr(NSLayoutAttributeBottomMargin)
        NormalAttr(NSLayoutAttributeLeadingMargin)
        NormalAttr(NSLayoutAttributeTrailingMargin)
        NormalAttr(NSLayoutAttributeCenterXWithinMargins)
        NormalAttr(NSLayoutAttributeCenterYWithinMargins)
        
        WHAttr(NSLayoutAttributeWidth)
        WHAttr(NSLayoutAttributeHeight)
        
        return self;
    };
}

- (void (^)(void))uninstall {
    return ^() {
        if (self->layoutConstraint) {
            if (self->layoutConstraint.isActive) {
                [self->layoutConstraint setActive:NO];
            }
            [self->installedView removeConstraint:self->layoutConstraint];
            self->layoutConstraint = nil;
        }
    };
}

@end

@interface ZLAutoLayout ()

@property (nonatomic, weak) UIView *view;

- (instancetype)initWithView:(UIView *)view;

@end

@implementation ZLAutoLayout

- (instancetype)initWithView:(UIView *)view {
    if (self = [super init]) {
        self.view = view;
    }
    
    return self;
}

- (ZLConstraint *)left {
    return [[ZLConstraint alloc] initWithItem:self.view attribute:NSLayoutAttributeLeft];
}

- (ZLConstraint *)top {
    return [[ZLConstraint alloc] initWithItem:self.view attribute:NSLayoutAttributeTop];
}

- (ZLConstraint *)right {
    return [[ZLConstraint alloc] initWithItem:self.view attribute:NSLayoutAttributeRight];
}

- (ZLConstraint *)bottom {
    return [[ZLConstraint alloc] initWithItem:self.view attribute:NSLayoutAttributeBottom];
}

- (ZLConstraint *)leading {
    return [[ZLConstraint alloc] initWithItem:self.view attribute:NSLayoutAttributeLeading];
}

- (ZLConstraint *)trailing {
    return [[ZLConstraint alloc] initWithItem:self.view attribute:NSLayoutAttributeTrailing];
}

- (ZLConstraint *)centerX {
    return [[ZLConstraint alloc] initWithItem:self.view attribute:NSLayoutAttributeCenterX];
}

- (ZLConstraint *)centerY {
    return [[ZLConstraint alloc] initWithItem:self.view attribute:NSLayoutAttributeCenterY];
}

- (ZLConstraint *)width {
    return [[ZLConstraint alloc] initWithItem:self.view attribute:NSLayoutAttributeWidth];
}

- (ZLConstraint *)height {
    return [[ZLConstraint alloc] initWithItem:self.view attribute:NSLayoutAttributeHeight];
}

- (ZLConstraint *)baseline {
    return [[ZLConstraint alloc] initWithItem:self.view attribute:NSLayoutAttributeBaseline];
}

- (ZLConstraint *)firstBaseline {
    return [[ZLConstraint alloc] initWithItem:self.view attribute:NSLayoutAttributeFirstBaseline];
}

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)
- (ZLConstraint *)leftMargin {
    return [[ZLConstraint alloc] initWithItem:self.view attribute:NSLayoutAttributeLeftMargin];
}

- (ZLConstraint *)topMargin {
    return [[ZLConstraint alloc] initWithItem:self.view attribute:NSLayoutAttributeTopMargin];
}

- (ZLConstraint *)rightMargin {
    return [[ZLConstraint alloc] initWithItem:self.view attribute:NSLayoutAttributeRightMargin];
}

- (ZLConstraint *)bottomMargin {
    return [[ZLConstraint alloc] initWithItem:self.view attribute:NSLayoutAttributeBottomMargin];
}

- (ZLConstraint *)leadingMargin {
    return [[ZLConstraint alloc] initWithItem:self.view attribute:NSLayoutAttributeLeadingMargin];
}

- (ZLConstraint *)trailingMargin {
    return [[ZLConstraint alloc] initWithItem:self.view attribute:NSLayoutAttributeTrailingMargin];
}

- (ZLConstraint *)centerXWithinMargins {
    return [[ZLConstraint alloc] initWithItem:self.view attribute:NSLayoutAttributeCenterXWithinMargins];
}

- (ZLConstraint *)centerYWithinMargins {
    return [[ZLConstraint alloc] initWithItem:self.view attribute:NSLayoutAttributeCenterYWithinMargins];
}
#endif

@end

static void *ZLAutoLayoutAssociatedKey = &ZLAutoLayoutAssociatedKey;

@implementation UIView (ZLAutoLayout)

- (ZLAutoLayout *)zla {
    ZLAutoLayout *al = objc_getAssociatedObject(self, ZLAutoLayoutAssociatedKey);
    if (al == nil) {
        al = [[ZLAutoLayout alloc] initWithView:self];
        objc_setAssociatedObject(self, ZLAutoLayoutAssociatedKey, al, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return al;
}

@end
