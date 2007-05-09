//
//  STNPostgreSQLType.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 08.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import "STNPostgreSQLTypes.h"


@implementation STNPostgreSQLTypes

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

- (NSString *)typeWithOid:(unsigned int)oid
{
    return [_types objectForKey:[NSNumber numberWithUnsignedInt:oid]];
}

- (unsigned int)oidForType:(NSString *)type
{
    NSArray *allKeys = [_types allKeysForObject:type];
    if ([allKeys count] > 0) {
        return [[allKeys objectAtIndex:0] unsignedIntValue];
    } else {
        return 0;
    }
}

@end
