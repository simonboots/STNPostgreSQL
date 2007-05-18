//
//  STTPostgreSQLParameteredStatementTests.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 17.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import "STTPostgreSQLParameteredStatementTests.h"


@implementation STTPostgreSQLParameteredStatementTests

- (void)setUp
{
    _conn = [[STNPostgreSQLConnection alloc] init];
    _pleaseWait = NO;
    NSError *error;
    
    [_conn setUser:@"sst"];
    [_conn setHost:@"localhost"];
    [_conn setDatabaseName:@"postgres"];
    [_conn setSSLMode:STNPostgreSQLConnectionSSLModePrefer];
    STAssertTrue([_conn connect:&error], @"connect should return YES (%@)", [[error userInfo] objectForKey:@"errormessage"]);
}

- (void)testValidStatement
{
    STNPostgreSQLParameteredStatement *statement = [[STNPostgreSQLParameteredStatement alloc] init];
    [statement setConnection:_conn];
    
    [statement setStatement:@"INSERT INTO test VALUES($1, $2)"];
    [statement addParameterWithValue:@"4712" type:@"int8" length:0 format:0];
    [statement addParameterWithValue:@"SimonSt" type:@"varchar" length:0 format:0];
    
    NSError *error;
    
    STAssertTrue([statement execute:&error], @"Statement should be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    [statement release];
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
