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
#import "STNPostgreSQLConnection.h"
#import "STNPostgreSQLResult.h"
#import "STNPostgreSQLErrorField.h"

@interface STNPostgreSQLStatement : NSObject {
    NSString *_statement;
    STNPostgreSQLConnection *_connection;
    STNPostgreSQLConnection *_temporaryConnection;
    STNPostgreSQLResult *_result;
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
- (STNPostgreSQLConnection *)primaryConnection;

- (BOOL)execute:(NSError **)error;
- (BOOL)executeWithConnection:(STNPostgreSQLConnection *)connection error:(NSError **)error;
- (void)startExecution;
- (void)startExecutionWithConnection:(STNPostgreSQLConnection *)connection;
- (void)executeWithDelegateCalls:(id)param;

- (STNPostgreSQLResult *)result;

- (STNPostgreSQLErrorField *)generateErrorField:(PGresult *)result;

@end

@interface NSObject (STNPostgreSQLStatementDelegateMethods)
- (BOOL)executionAttemptShouldStart;
- (void)executionAttemptWillStart;
- (void)executionAttemptEnded:(BOOL)success error:(NSError *)error;
@end
