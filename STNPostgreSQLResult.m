//
//  STNPostgreSQLResult.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 02.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import "STNPostgreSQLResult.h"


@implementation STNPostgreSQLResult

+ (STNPostgreSQLResult *)resultWithPGresult:(PGresult*)result
{
    return [[[STNPostgreSQLResult alloc] initWithPGresult:result] autorelease];
}

- (id)init
{
    return [self initWithPGresult:NULL];
}

- (id)initWithPGresult:(PGresult *)result {
    self = [super init];
    if (self != nil) {
        _result = result;
    }
    return self;
}


@end
