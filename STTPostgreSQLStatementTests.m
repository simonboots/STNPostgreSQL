//
//  STTPostgreSQLStatementTests.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 22.04.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//
//  For PostgreSQL Copyright information read PostgreSQL_COPYRIGHT
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

#import "STTPostgreSQLStatementTests.h"


@implementation STTPostgreSQLStatementTests

- (void)setUp
{
    _conn = [[STNPostgreSQLConnection alloc] init];
    _pleaseWait = NO;
    NSError *error;
    
    [_conn setUser:[NSString stringWithCString:UT_USERNAME encoding:NSASCIIStringEncoding]];
    [_conn setPassword:[NSString stringWithCString:UT_PASSWD encoding:NSASCIIStringEncoding]];
    [_conn setHost:[NSString stringWithCString:UT_HOST encoding:NSASCIIStringEncoding]];
    [_conn setDatabaseName:[NSString stringWithCString:UT_DATABASE encoding:NSASCIIStringEncoding]];
    [_conn setPort:[NSString stringWithCString:UT_PORT encoding:NSASCIIStringEncoding]];
    [_conn setSSLMode:STNPostgreSQLConnectionSSLModePrefer];
    STAssertTrue([_conn connect:&error], @"connect should return YES (%@)", [[error userInfo] objectForKey:@"errormessage"]);
}

- (void)testValidStatement
{
    STNPostgreSQLStatement *statement = [[STNPostgreSQLStatement alloc] initWithConnection:_conn];
    [statement setStatement:@"SELECT 1+1"];
    NSError *error;
    
    STAssertTrue([statement execute:&error], @"Statement should be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    [statement release];
}
    
- (void)testInvalidStatement
{
    STNPostgreSQLStatement *statement = [[STNPostgreSQLStatement alloc] initWithConnection:_conn];
    [statement setStatement:@"SELECT DOES NOT WORK"];
    NSError *error;
    
    STAssertFalse([statement execute:&error], @"Statement should fail (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    [statement release];
}

- (void)testValidStatementThreaded
{
    _pleaseWait = YES;
    STNPostgreSQLStatement *statement = [[STNPostgreSQLStatement alloc] initWithConnection:_conn];
    [statement setStatement:@"SELECT 1+1"];
    [statement setDelegate:self];
    [statement startExecution];
}

- (BOOL)executionAttemptShouldStart
{
    NSLog(@"delegate method \"executionAttemptShouldStart\" called (1/3)");
    return YES;
}

- (void)executionAttemptWillStart
{
    NSLog(@"delegate method \"executionAttemptWillStart\" called (2/3)");
}

- (void)executionAttemptEnded:(BOOL)success error:(NSError *)error
{
    NSLog(@"delegate method \"executionAttemptEnded\" called (3/3)");
    STAssertTrue(success, @"Statement should be executed successfuly (%@)", [[error userInfo] objectForKey:@"errormessage"]);
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
