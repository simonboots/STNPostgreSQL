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

@class STNPostgreSQLConnection;
@class STNPostgreSQLStatement;

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

- (BOOL)executeWithConnection:(STNPostgreSQLConnection *)connection error:(NSError **)error;
- (void)startExecutionWithConnection:(STNPostgreSQLConnection *)connection;

@end

@interface NSObject (STNPostgreSQLTransactionDelegateMethods)
// transaction methods
- (BOOL)transactionAttemptShouldStart;
- (void)transactionAttemptWillStart;
- (BOOL)shouldExecuteStatement:(STNPostgreSQLStatement *)statement atIndex:(unsigned int)index ofTotal:(unsigned int)total;
- (void)transactionAttemptEnded:(BOOL)success error:(NSError *)error;
@end
