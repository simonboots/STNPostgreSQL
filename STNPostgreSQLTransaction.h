//
//  STNPostgreSQLTransaction.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 03.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import <Cocoa/Cocoa.h>


@interface STNPostgreSQLTransaction : NSObject {
    NSMutableArray *_statements;
    id _delegate;
}

+ (STNPostgreSQLTransaction *)transaction;
+ (STNPostgreSQLTransaction *)transactionWithStatement:(STNPostgreSQLStatement *)statement;
+ (STNPostgreSQLTransaction *)transactionWithStatements:(NSArray *)statements;

- (id)initWithStatement:(STNPostgreSQLStatement *)statement;
- (id)initWithStatements:(NSArray *)statements;

- (void)setStatements:(NSArray *)statements;
- (NSMutableArray *)statements;

- (void)setDelegate:(id)delegate;
- (id)delegate;

- (void)addStatement:(STNPostgreSQLStatement *)statement;
- (STNPostgreSQLStatement *)statementAtIndex:(unsigned int)index;
- (void)insertStatement:(STNPostgreSQLStatement *)statement atIndex:(unsigned int)index;
- (void)dropStatementAtIndex:(unsigned int)index;
- (int)statementCount;
- (void)clearStatements;

- (BOOL)execute:(NSError **)error;
- (void)startExecution;


@end
