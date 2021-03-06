//
//  STNPostgreSQLType.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 08.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//
//  For PostgreSQL Copyright information read PostgreSQL_COPYRIGHT
//
//  Redistribution and use in source and binary forms, with or
//  without modification, are permitted provided that the
//  following conditions are met:
//
//  1. Redistributions of source code must retain the above
//  copyright notice, this list of conditions and the following
//  disclaimer.
//
//  2. Redistributions in binary form must reproduce the above
//  copyright notice, this list of conditions and the following
//  disclaimer in the documentation and/or other materials
//  provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOTLIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
//  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
//  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
//  OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "STNPostgreSQLTypes.h"

@implementation STNPostgreSQLTypes

#pragma mark initializers/dealloc

+ (STNPostgreSQLTypes *)typesWithDictionary:(NSDictionary *)dictionary
{
    return [[[STNPostgreSQLTypes alloc] initWithDictionary:dictionary] autorelease];
}

- (id)init
{
    return [self initWithDictionary:nil];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self != nil) {
        _types = [dictionary retain];
    }
    return self;
}

- (void)dealloc
{
    [[self types] release];
    [super dealloc];
}

#pragma mark getters/setters

- (void)setTypes:(NSDictionary *)types
{
    if (types != _types) {
        [_types release];
        _types = [types retain];
    }
}

- (NSDictionary *)types
{
    return _types;
}

#pragma mark type information

- (NSString *)typeWithOid:(unsigned int)oid
{
    return [_types objectForKey:[NSNumber numberWithUnsignedInt:oid]];
}

- (unsigned int)oidForType:(NSString *)type
{
    if (type == nil) { return 0; }
    NSArray *allKeys = [_types allKeysForObject:type];
    if ([allKeys count] > 0) {
        return [[allKeys objectAtIndex:0] unsignedIntValue];
    } else {
        return 0;
    }
}

@end
