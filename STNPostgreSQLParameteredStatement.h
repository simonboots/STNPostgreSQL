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
- (int)addParameterWithValue:(id)value type:(NSString *)type length:(int)length format:(int)format;
- (int)parameterCount;
- (void)clearParameters;
- (NSArray *)parameters;
- (void)setParameters:(NSArray *)parameters;
- (void)dropParameterAtIndex:(unsigned int)index;


@end
