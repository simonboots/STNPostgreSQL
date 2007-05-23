//
//  STNPostgreSQLResult.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 02.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import <Cocoa/Cocoa.h>
#import "libpq-fe.h"

enum STNPostgreSQLKeyTypeModifier {
    STNPostgreSQLKeyTypeString = 0,
    STNPostgreSQLKeyTypeIntNumber = 1,
    STNPostgreSQLKeyTypeFloatNumber = 2,
    STNPostgreSQLKeyTypeDoubleNumber = 3
};

@interface STNPostgreSQLResult : NSObject {
    PGresult *_result;
}

+ (STNPostgreSQLResult *)resultWithPGresult:(PGresult*)result;

- (id)initWithPGresult:(PGresult *)result;

- (int)numberOfTuples;
- (int)numberOfFields;
- (NSString *)nameOfFieldAtIndex:(int)index;
- (int)indexOfFieldWithName:(NSString *)name;
- (int)indexOfFieldWithinTableAtIndex:(int)index;
- (NSString *)valueAtRow:(int)row column:(int)column;
- (BOOL)hasNullValueAtRow:(int)row column:(int)column;
- (NSString *)kindOfCommand;
- (int)numberOfAffectedRows;

- (NSDictionary *)dictionaryWithKeyColumn:(int)keycolumn valueColumn:(int)valuecolumn keyType:(int)modifier;

@end
