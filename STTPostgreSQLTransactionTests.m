//
//  STTPostgreSQLTransactionTests.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 22.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import "STTPostgreSQLTransactionTests.h"

@implementation STTPostgreSQLTransactionTests

- (void)setUp
{
    conn = [[STNPostgreSQLConnection alloc] init];
    pleaseWait = NO;
    callbackcounter = 0;
    NSError *error;
    
    [conn setUser:@"sst"];
    [conn setHost:@"localhost"];
    [conn setDatabaseName:@"postgres"];
    [conn setSSLMode:STNPostgreSQLConnectionSSLModePrefer];
    STAssertTrue([conn connect:&error], @"connect should return YES (%@)", [[error userInfo] objectForKey:@"errormessage"]);
}

- (void)testSuccessfulTransaction
{
    STNPostgreSQLStatement *statement1 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO test VALUES(1123, 'successful')"];
    STNPostgreSQLStatement *statement2 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO test VALUES(1234, 'also successful')"];
    STNPostgreSQLTransaction *transaction = [STNPostgreSQLTransaction transaction];
    
    NSError *error;
    [transaction addStatement:statement1];
    [transaction addStatement:statement2];
    
    STAssertTrue([transaction executeWithConnection:conn error:&error], @"Transaction should be executed (error: %@)", [[error userInfo] objectForKey:@"errormessage"]);
}

- (void)testUnsuccessfulTransaction
{
    STNPostgreSQLStatement *statement1 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO test VALUES (1222, 'not successful'"];
    STNPostgreSQLTransaction *transaction = [STNPostgreSQLTransaction transactionWithStatement:statement1];
    
    NSError *error;
    STAssertFalse([transaction executeWithConnection:conn error:&error], @"Transaction must fail (%@)", [[error userInfo] objectForKey:@"errormessage"]);
}

- (void)testTransactionThreaded
{
    pleaseWait = YES;
    
    STNPostgreSQLStatement *statement1 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO test VALUES(1155, 'Thread successful')"];
    STNPostgreSQLStatement *statement2 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO test VALUES(1256, 'also successful')"];
    STNPostgreSQLTransaction *transaction = [STNPostgreSQLTransaction transaction];
    [transaction setDelegate:self];
    
    [transaction addStatement:statement1];
    [transaction addStatement:statement2];
    
    [transaction startExecutionWithConnection:conn];
}

- (void)testStatementCallback
{
    STNPostgreSQLStatement *statement1 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO test VALUES(1123, 'successful')"];
    STNPostgreSQLStatement *statement2 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO test VALUES(1234, 'also successful')"];
    STNPostgreSQLTransaction *transaction = [STNPostgreSQLTransaction transaction];
    [transaction setDelegate:self];
    
    NSError *error;
    [transaction addStatement:statement1];
    [transaction addStatement:statement2];
    
    STAssertTrue([transaction executeWithConnection:conn error:&error], @"Statement should be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    
    STAssertEquals(callbackcounter, 2, @"callbackcounter should be 2");
}

- (BOOL)shouldExecuteStatement:(STNPostgreSQLStatement *)statement atIndex:(unsigned int)index ofTotal:(unsigned int)total
{
    NSLog(@"executing statement (%@) atIndex %d ofTotal %d", [statement statement], index, total);
    callbackcounter++;
    return YES;
}

- (BOOL)transactionAttemptShouldStart
{
    NSLog(@"transactionAttemptShouldStart called");
    return YES;
}

- (void)transactionAttemptWillStart
{
    NSLog(@"transactionAttemptWillStart called");
}

- (void)transactionAttemptEnded:(BOOL)success error:(NSError *)error
{
    NSLog(@"transactionAttemptEnded:error: called");
    STAssertTrue(success, @"Transaction failed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    pleaseWait = NO;
}

- (void)tearDown
{
    while (pleaseWait == YES) {
        sleep(1);
    }
    
    [conn disconnect];
    [conn release];
}

@end
