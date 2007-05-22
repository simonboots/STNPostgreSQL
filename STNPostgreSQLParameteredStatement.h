//
//  STNPostgreSQLParameteredStatement.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 13.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import <Cocoa/Cocoa.h>
#import "STNPostgreSQLStatement.h"

@class STNPostgreSQLStatementParameter;

@interface STNPostgreSQLParameteredStatement : STNPostgreSQLStatement {
    NSMutableArray *_parameters;
}

+ (STNPostgreSQLParameteredStatement *)statementWithStatement:(NSString *)statement
                                                andParameters:(NSArray *)parameter;
+ (STNPostgreSQLParameteredStatement *)statementWithConnection:(STNPostgreSQLConnection *)connection 
                                                  andStatement:(NSString *)statement 
                                                 andParameters:(NSArray *)parameters;

- (int)addParameter:(STNPostgreSQLStatementParameter *)parameter;
- (int)addParameterWithValue:(id)value type:(NSString *)type;
- (int)parameterCount;
- (void)clearParameters;
- (NSArray *)parameters;
- (void)setParameters:(NSArray *)parameters;
- (STNPostgreSQLStatementParameter *)parameterAtIndex:(unsigned int)index;
- (void)insertParameter:(STNPostgreSQLStatementParameter *)parameter atIndex:(unsigned int)index;
- (void)dropParameterAtIndex:(unsigned int)index;


@end
