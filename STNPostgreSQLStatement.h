//
//  STNPostgreSQLStatement.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 01.04.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import <Cocoa/Cocoa.h>
#import "STNPostgreSQL.h"
#import "STNPostgreSQLErrorField.h"

@interface STNPostgreSQLStatement : NSObject {
    NSString *_statement;
    STNPostgreSQLConnection *_connection;
    id _delegate;
}

+ (STNPostgreSQLStatement *)statement;
+ (STNPostgreSQLStatement *)statementWithConnection:(STNPostgreSQLConnection *)connection;
+ (STNPostgreSQLStatement *)statementWithStatement:(NSString *)statement;
+ (STNPostgreSQLStatement *)statementWithConnection:(STNPostgreSQLConnection *)connection andStatement:(NSString *)statement;

- (id)initWithConnection:(STNPostgreSQLConnection *)connection;

- (void)setStatement:(NSString *)statement;
- (NSString *)statement;

- (void)setDelegate:(id)delegate;
- (id)delegate;

- (void)setConnection:(STNPostgreSQLConnection *)connection;
- (STNPostgreSQLConnection *)connection;

- (BOOL)execute:(NSError **)error;
- (void)startExecution;
- (void)executeWithDelegateCalls:(id)param;

- (STNPostgreSQLErrorField *)generateErrorField:(PGresult *)result;

@end

@interface NSObject (STNPostgreSQLStatementDelegateMethods)
- (BOOL)executionAttemptShouldStart;
- (void)executionAttemptWillStart;
- (void)executionAttemptEnded:(BOOL)success error:(NSError *)error;
    // disconnection methods
    // - (BOOL)disconnectionAttemptShouldStart;
    // - (void)disconnectionAttemptWillStart;
    // - (void)disconnectionAttemptEnded;
@end
