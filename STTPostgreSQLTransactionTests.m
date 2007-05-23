//
//  STTPostgreSQLTransactionTests.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 22.05.07.
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
    STNPostgreSQLStatement *statement1 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO stnpostgresqltests VALUES(20, 'twenty')"];
    STNPostgreSQLStatement *statement2 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO stnpostgresqltests VALUES(21, 'twentyone')"];
    STNPostgreSQLTransaction *transaction = [STNPostgreSQLTransaction transaction];
    
    NSError *error;
    [transaction addStatement:statement1];
    [transaction addStatement:statement2];
    
    STAssertTrue([transaction executeWithConnection:_conn error:&error], @"Transaction should be executed (error: %@)", [[error userInfo] objectForKey:@"errormessage"]);
}

- (void)testUnsuccessfulTransaction
{
    STNPostgreSQLStatement *statement1 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO stnpostgresqltests VALUES (22, 'not successful'"];
    STNPostgreSQLTransaction *transaction = [STNPostgreSQLTransaction transactionWithStatement:statement1];
    
    NSError *error;
    STAssertFalse([transaction executeWithConnection:_conn error:&error], @"Transaction must fail (%@)", [[error userInfo] objectForKey:@"errormessage"]);
}

- (void)testTransactionThreaded
{
    _pleaseWait = YES;
    
    STNPostgreSQLStatement *statement1 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO stnpostgresqltests VALUES(23, 'twentythree')"];
    STNPostgreSQLStatement *statement2 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO stnpostgresqltests VALUES(24, 'twentyfour')"];
    STNPostgreSQLTransaction *transaction = [STNPostgreSQLTransaction transaction];
    [transaction setDelegate:self];
    
    [transaction addStatement:statement1];
    [transaction addStatement:statement2];
    
    [transaction startExecutionWithConnection:_conn];
}

- (void)testStatementCallback
{
    STNPostgreSQLStatement *statement1 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO stnpostgresqltests VALUES(25, 'twentyfive')"];
    STNPostgreSQLStatement *statement2 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO stnpostgresqltests VALUES(26, 'twentysix')"];
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
