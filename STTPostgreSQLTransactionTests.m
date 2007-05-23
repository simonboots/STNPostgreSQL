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
    _conn = [[STNPostgreSQLConnection alloc] init];
    _pleaseWait = NO;
    _callbackcounter = 0;
    NSError *error;
    
    [_conn setUser:[NSString stringWithCString:UT_USERNAME encoding:NSASCIIStringEncoding]];
    [_conn setPassword:[NSString stringWithCString:UT_PASSWD encoding:NSASCIIStringEncoding]];
    [_conn setHost:[NSString stringWithCString:UT_HOST encoding:NSASCIIStringEncoding]];
    [_conn setDatabaseName:[NSString stringWithCString:UT_DATABASE encoding:NSASCIIStringEncoding]];
    [_conn setPort:[NSString stringWithCString:UT_PORT encoding:NSASCIIStringEncoding]];
    [_conn setSSLMode:STNPostgreSQLConnectionSSLModePrefer];
    STAssertTrue([_conn connect:&error], @"connect should return YES (%@)", [[error userInfo] objectForKey:@"errormessage"]);
}

- (void)testSuccessfulTransaction
{
    STNPostgreSQLStatement *statement1 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO test VALUES(1123, 'successful')"];
    STNPostgreSQLStatement *statement2 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO test VALUES(1234, 'also successful')"];
    STNPostgreSQLTransaction *transaction = [STNPostgreSQLTransaction transaction];
    
    NSError *error;
    [transaction addStatement:statement1];
    [transaction addStatement:statement2];
    
    STAssertTrue([transaction executeWithConnection:_conn error:&error], @"Transaction should be executed (error: %@)", [[error userInfo] objectForKey:@"errormessage"]);
}

- (void)testUnsuccessfulTransaction
{
    STNPostgreSQLStatement *statement1 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO test VALUES (1222, 'not successful'"];
    STNPostgreSQLTransaction *transaction = [STNPostgreSQLTransaction transactionWithStatement:statement1];
    
    NSError *error;
    STAssertFalse([transaction executeWithConnection:_conn error:&error], @"Transaction must fail (%@)", [[error userInfo] objectForKey:@"errormessage"]);
}

- (void)testTransactionThreaded
{
    _pleaseWait = YES;
    
    STNPostgreSQLStatement *statement1 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO test VALUES(1155, 'Thread successful')"];
    STNPostgreSQLStatement *statement2 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO test VALUES(1256, 'also successful')"];
    STNPostgreSQLTransaction *transaction = [STNPostgreSQLTransaction transaction];
    [transaction setDelegate:self];
    
    [transaction addStatement:statement1];
    [transaction addStatement:statement2];
    
    [transaction startExecutionWithConnection:_conn];
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
    
    STAssertTrue([transaction executeWithConnection:_conn error:&error], @"Statement should be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    
    STAssertEquals(_callbackcounter, 2, @"callbackcounter should be 2");
}

- (BOOL)shouldExecuteStatement:(STNPostgreSQLStatement *)statement atIndex:(unsigned int)index ofTotal:(unsigned int)total
{
    NSLog(@"executing statement (%@) atIndex %d ofTotal %d", [statement statement], index, total);
    _callbackcounter++;
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
    _pleaseWait = NO;
}

- (void)tearDown
{
    while (_pleaseWait == YES) {
        sleep(1);
    }
    
    [_conn disconnect];
    [_conn release];
}

@end
