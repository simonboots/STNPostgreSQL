//
//  STTPostgreSQLResultTests.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 03.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import "STTPostgreSQLResultTests.h"

@implementation STTPostgreSQLResultTests

- (void)setUp
{
    _conn = [[STNPostgreSQLConnection alloc] init];
    NSError *error;
    
    [_conn setUser:@"sst"];
    [_conn setHost:@"localhost"];
    [_conn setDatabaseName:@"postgres"];
    [_conn setSSLMode:STNPostgreSQLConnectionSSLModePrefer];
    STAssertTrue([_conn connect:&error], @"connect should return YES (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    
    _statement = [[STNPostgreSQLStatement alloc] initWithConnection:_conn];
    [_statement setStatement:@"SELECT 'f1' AS f1, 'f2' AS f2, 'f3' AS f3"];
    
    STAssertTrue([_statement execute:&error], @"Statement couldn't be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    
    _result = [_statement result];
}

- (void)tearDown
{
    [_conn disconnect];
    [_conn release];
}

- (void)testNumberOfTuples
{
    // not using standard statement
    STNPostgreSQLStatement *statement = [[STNPostgreSQLStatement alloc] initWithConnection:_conn];
    [statement setStatement:@"SELECT * FROM test"];
    NSError *statementError;
    
    STAssertTrue([statement execute:&statementError], @"Statement should be executed");
    
    STNPostgreSQLResult *result = [statement result];
    
    STAssertEquals([result numberOfTuples], 3, @"Tuple count does not match (is %d)!", [result numberOfTuples]);
}

- (void)testNumberOfFields
{    
    STAssertEquals([_result numberOfFields], 3, @"Field count does not match (is %d)!", [_result numberOfFields]);
}

- (void)testFieldName
{
    STAssertEqualObjects([_result nameOfFieldAtIndex:2], @"f3", @"Field at index 2 is not 'f3' (is %@)", [_result nameOfFieldAtIndex:2]);
}

- (void)testFieldIndex
{
    STAssertEquals([_result indexOfFieldWithName:@"f2"], 1, @"Field index of f2 is not 1 (is %d)", [_result indexOfFieldWithName:@"f1"]);
}

- (void)testFieldIndexWithinTable
{
    // not using standard statement
    STNPostgreSQLStatement *statement = [[STNPostgreSQLStatement alloc] initWithConnection:_conn];
    NSError *error;
    
    [statement setStatement:@"SELECT name FROM test"];
    
    STAssertTrue([statement execute:&error], @"Statement couldn't be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    
    STNPostgreSQLResult *result = [statement result];
    
    int indexAtTable = [result indexOfFieldWithinTableAtIndex:[result indexOfFieldWithName:@"name"]];
    STAssertEquals(indexAtTable, 2, @"index at table should be 2 (is %d)", indexAtTable);
}

@end
