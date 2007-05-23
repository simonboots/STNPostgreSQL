//
//  STTPostgreSQLStatementTests.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 22.04.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
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
