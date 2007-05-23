//
//  STNPostgreSQLTransaction.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 03.05.07.
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
