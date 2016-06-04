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

#import <objc/runtime.h>
#import <objc/message.h>

#import "NSMixin.h"

@implementation NSMixin


@end

static void NSMixinCopyMethodsFromClassToClass(Class from, Class to) {
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(from, &methodCount);

    if (methods == NULL) {
        return;
    }

    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        SEL sel = method_getName(method);
        IMP imp = method_getImplementation(method);
        const char *types = method_getTypeEncoding(method);
        class_addMethod(to, sel, imp, types);
    }

    free(methods);
}

void NSMixinApplyToClass(Class mixin, Class target) {
    Class current = mixin;

    while (current != [NSMixin superclass]) {
        NSMixinCopyMethodsFromClassToClass(current, target);
        NSMixinCopyMethodsFromClassToClass(object_getClass(current), target);

        current = [current superclass];
    }
}

__attribute__((constructor)) static void NSMixinInitialize() {
    int classCount = objc_getClassList(NULL, 0);

    Class *classes = malloc(sizeof(Class) * classCount);
    objc_getClassList(classes, classCount);

    for (int i = 0; i < classCount; i++) {
        Class class = classes[i];
        Class metaclass = object_getClass(class);

        unsigned int methodCount = 0;
        Method *methods = class_copyMethodList(metaclass, &methodCount);

        if (methods == NULL) {
            continue;
        }

        for (unsigned int j = 0; j < methodCount; j++) {
            Method method = methods[j];
            SEL sel = method_getName(method);
            const char *name = sel_getName(sel);

            if (strstr(name, NSMixinQuote(NSMixinMethodPrefix)) == name) {
                objc_msgSend(class, sel);
            }
        }

        free(methods);
    }

    free(classes);
}


