//
//  ZLAutoLayout.h
//  ZLAutoLayout
//
//  Created by lylaut on 2021/9/26.
//

#import <Foundation/Foundation.h>

@interface ZLConstraint : NSObject

- (ZLConstraint * (^)(id item))equalTo;

- (ZLConstraint * (^)(id item))greaterThanOrEqualTo;

- (ZLConstraint * (^)(id item))lessThanOrEqualTo;

- (ZLConstraint * (^)(UILayoutPriority priority))priority;

- (ZLConstraint * (^)(CGFloat m))multiplier;

- (ZLConstraint * (^)(CGFloat c))constant;

- (ZLConstraint * (^)(BOOL safeArea))withSafeArea;

- (ZLConstraint * (^)(void))install;

- (void (^)(void))uninstall;

@end

@interface ZLAutoLayout : NSObject

- (ZLConstraint *)left;

- (ZLConstraint *)top;

- (ZLConstraint *)right;

- (ZLConstraint *)bottom;

- (ZLConstraint *)leading;

- (ZLConstraint *)trailing;

- (ZLConstraint *)centerX;

- (ZLConstraint *)centerY;

- (ZLConstraint *)width;

- (ZLConstraint *)height;

- (ZLConstraint *)baseline;

- (ZLConstraint *)firstBaseline;

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)
- (ZLConstraint *)leftMargin;

- (ZLConstraint *)topMargin;

- (ZLConstraint *)rightMargin;

- (ZLConstraint *)bottomMargin;

- (ZLConstraint *)leadingMargin;

- (ZLConstraint *)trailingMargin;

- (ZLConstraint *)centerXWithinMargins;

- (ZLConstraint *)centerYWithinMargins;
#endif

@end

@interface UIView (ZLAutoLayout)

@property (nonatomic, strong, readonly) ZLAutoLayout *zla;

@end
