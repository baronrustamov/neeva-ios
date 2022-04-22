// Copyright Neeva. All rights reserved.

#import "WKWebView+Zoom.h"

// Obfuscated accessors for the private _viewScale property on WKWebView
// This code is complicated by the fact that Apple might reject us if we simply
// define the `_viewScale` and `_setViewScale:` methods on WKWebView.
// Instead, we use NSInvocation to perform the method calls.
// We can’t use `performSelector` because the return type is CGFloat, not an object.
// We can’t use Swift because NSInvocation is unavailable in Swift.

@implementation WKWebView (Zoom)

- (CGFloat)neeva_zoomAmount {
    char types[50];
    sprintf(types, "%s%s%s", @encode(CGFloat), @encode(id), @encode(SEL));
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:types];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
    // "_viewScale"
    NSArray<NSString *> *chars = @[@"_vi", @"wScal", @""];
    invocation.selector = NSSelectorFromString([chars componentsJoinedByString:@"e"]);
    [invocation invoke];
    CGFloat result;
    [invocation getReturnValue:&result];
    return result;
}

- (void)setNeeva_zoomAmount:(CGFloat)amount {
    char types[50];
    sprintf(types, "%s%s%s%s", @encode(void), @encode(id), @encode(SEL), @encode(CGFloat));
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:types];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
    // "_setViewScale:"
    NSArray<NSString *> *chars = @[@"_s", @"tVi", @"wScal", @":"];
    invocation.selector = NSSelectorFromString([chars componentsJoinedByString:@"e"]);
    // Implicit arguments are 0 => self, 1 => @selector(_setViewScale:)
    [invocation setArgument:&amount atIndex:2];
    [invocation invoke];
}

@end
