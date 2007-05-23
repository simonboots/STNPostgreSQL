//
//  STNPostgreSQLErrorField.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 15.04.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import "STNPostgreSQL.h"
#import "STNPostgreSQLErrorField.h"

@implementation STNPostgreSQLErrorField

#pragma mark initializers/dealloc

+ (STNPostgreSQLErrorField *)errorFieldWithPGResult:(PGresult *)result
{
    return [[[self alloc] initWithPGResult:result] autorelease];
}

- (id) init {
    return [self initWithPGResult:NULL];
}

- (id) initWithPGResult:(PGresult *)result {
    self = [super init];
    if (self != nil) {
        NSArray *keys = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:STNPostgreSQLSeverityErrorField],
                                                                  [NSNumber numberWithInt:STNPostgreSQLSQLStateErrorField],
                                                                  [NSNumber numberWithInt:STNPostgreSQLPrimaryMessageErrorField],
                                                                  [NSNumber numberWithInt:STNPostgreSQLStatementPositionErrorField],
                                                                  [NSNumber numberWithInt:STNPostgreSQLDetailMessageErrorField],
                                                                  [NSNumber numberWithInt:STNPostgreSQLHintMessageErrorField],
                                                                  [NSNumber numberWithInt:STNPostgreSQLStatementPositionErrorField],
                                                                  [NSNumber numberWithInt:STNPostgreSQLInternalPositionErrorField],
                                                                  [NSNumber numberWithInt:STNPostgreSQLInternalQueryErrorField],
                                                                  [NSNumber numberWithInt:STNPostgreSQLContextErrorField],
                                                                  [NSNumber numberWithInt:STNPostgreSQLSourceFileErrorField],
                                                                  [NSNumber numberWithInt:STNPostgreSQLSourceLineErrorField],
                                                                  [NSNumber numberWithInt:STNPostgreSQLSourceFunctionErrorField],
                                                                  nil];
        
        NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:[keys count]];
        NSEnumerator *enumerator = [keys objectEnumerator];
        id object;
        char *errorField = NULL;
        
        while ((object = [enumerator nextObject]) != nil) {
            
            if (result != NULL) {
                errorField = PQresultErrorField(result,[object intValue]);
            }
            
            if (errorField == NULL || result == NULL) {
                [values addObject:[NSNull null]];
            } else {
                [values addObject:[NSString stringWithUTF8String:errorField]];
            }
        }
        
        _errorField = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    }
    return self;
}

- (void)dealloc
{
    [_errorField release];
    [super dealloc];
}

#pragma mark field access

- (NSString *)valueForField:(unsigned int)field
{
    return [_errorField objectForKey:[NSNumber numberWithInt:field]];
}


@end
