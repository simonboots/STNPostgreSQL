//
//  STNPostgreSQLErrorField.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 15.04.07.
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
