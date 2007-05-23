//
//  STNPostgreSQLResult.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 02.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
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

#import "STNPostgreSQL.h"
#import "STNPostgreSQLResult.h"


@implementation STNPostgreSQLResult

#pragma mark initializers/dealloc

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

- (void)dealloc
{
    PQclear(_result);
    [super dealloc];
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

- (int)numberOfAffectedRows
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

- (NSDictionary *)dictionaryWithKeyColumn:(int)keycolumn valueColumn:(int)valuecolumn keyType:(int)modifier
{
    NSMutableArray *keys   = [NSMutableArray arrayWithCapacity:[self numberOfTuples]];
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:[self numberOfTuples]];
    int row = 0;
    for (row = 0; row < [self numberOfTuples]; row++) {
        // keys
        if (modifier != STNPostgreSQLKeyTypeString) {
            NSScanner *numberScanner = [NSScanner scannerWithString:[self valueAtRow:row column:keycolumn]];
            switch (modifier) {
            case STNPostgreSQLKeyTypeFloatNumber:
            {
                float floatkey;
                [numberScanner scanFloat:&floatkey];
                [keys addObject:[NSNumber numberWithFloat:floatkey]];
                break;
            }
            case STNPostgreSQLKeyTypeDoubleNumber:
            {
                double doublekey;
                [numberScanner scanDouble:&doublekey];
                [keys addObject:[NSNumber numberWithDouble:doublekey]];
                break;
            }
            case STNPostgreSQLKeyTypeIntNumber:
            default: 
            {
                int integerkey;
                [numberScanner scanInt:&integerkey];
                [keys addObject:[NSNumber numberWithInt:integerkey]];
                break;
            }
            }
        } else {
            [keys addObject:[self valueAtRow:row column:keycolumn]];
        }
        
        // values
        [values addObject:[self valueAtRow:row column:valuecolumn]];
    }
    
    return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}

@end
