//
//  STNPostgreSQLResult.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 02.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import "STNPostgreSQL.h"
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

#pragma mark result information

- (int)numberOfTuples
{
    return PQntuples(_result);
}

- (int)numberOfFields
{
    return PQnfields(_result);
}

- (NSString *)nameOfFieldAtIndex:(int)index
{
    char *name = PQfname(_result, index);
    
    if (name != NULL) {
        return [NSString stringWithCString:name encoding:NSASCIIStringEncoding];
    } else {
        return nil;
    }
}

- (int)indexOfFieldWithName:(NSString *)name
{
    return PQfnumber(_result, [name cStringUsingEncoding:NSASCIIStringEncoding]);
}

- (int)indexOfFieldWithinTableAtIndex:(int)index
{
    return PQftablecol(_result, index);
}

- (NSString *)valueAtRow:(int)row column:(int)column
{
    return [NSString stringWithCString:PQgetvalue(_result, row, column) encoding:NSASCIIStringEncoding];
}

- (BOOL)hasNullValueAtRow:(int)row column:(int)column
{
    if (PQgetisnull(_result, row, column) == 1) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)kindOfCommand
{
    return [NSString stringWithCString:PQcmdStatus(_result) encoding:NSASCIIStringEncoding];
}

- (int)numberOfRowsAffected
{
    NSString *rowsAffected = [NSString stringWithCString:PQcmdTuples(_result) encoding:NSASCIIStringEncoding];
    NSScanner *intScanner = [NSScanner scannerWithString:rowsAffected];
    int rows = 0;
    if ([intScanner scanInt:&rows]) {
        return rows;
    } else {
        return 0;
    }
}


@end
