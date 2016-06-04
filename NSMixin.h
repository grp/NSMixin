/*
 * Copyright (c) 2013-2016, Grant Paul
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>

@interface NSMixin : NSObject

@end

void NSMixinApplyToClass(Class mixin, Class target);

#define NSMixinPasteInternal(x, y) x ## y
#define NSMixinPaste(x, y) NSMixinPasteInternal(x, y)

#define NSMixinQuoteInternal(x) # x
#define NSMixinQuote(x) NSMixinQuoteInternal(x)

#define NSMixinMethodPrefix nsmixin_init_
#define NSMixinClassPrefix NSMixin_Class_

#define mixin_interface(m) \
    protocol m \
    @optional

#define mixin_implementation(m) \
    class NSMixinPaste(NSMixin_Dummy_, __COUNTER__); \
    @interface NSMixinPaste(NSMixinClassPrefix, m) : NSObject { } @end \
    @implementation NSMixinPaste(NSMixinClassPrefix, m)

#define mixin(m) \
    class NSMixinPaste(NSMixin_Dummy_, __COUNTER__); /* support @ before this */ \
    + (void)NSMixinPaste(NSMixinMethodPrefix, __COUNTER__) { /* counter for multiple mixins */ \
        NSMixinApplyToClass([NSMixinPaste(NSMixinClassPrefix, m) class], self); /* apply the mixin */ \
    } @class NSMixinPaste(NSMixin_Dummy_, __COUNTER__) /* support semicolon at the end */

