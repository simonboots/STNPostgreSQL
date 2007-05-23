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
    
    [_conn setUser:[NSString stringWithCString:UT_USERNAME encoding:NSASCIIStringEncoding]];
    [_conn setPassword:[NSString stringWithCString:UT_PASSWD encoding:NSASCIIStringEncoding]];
    [_conn setHost:[NSString stringWithCString:UT_HOST encoding:NSASCIIStringEncoding]];
    [_conn setDatabaseName:[NSString stringWithCString:UT_DATABASE encoding:NSASCIIStringEncoding]];
    [_conn setPort:[NSString stringWithCString:UT_PORT encoding:NSASCIIStringEncoding]];
    [_conn setSSLMode:STNPostgreSQLConnectionSSLModePrefer];
    STAssertTrue([_conn connect:&error], @"connect should return YES (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    
    _statement = [[STNPostgreSQLStatement alloc] initWithConnection:_conn];
    [_statement setStatement:@"SELECT 'f1' AS f1, 'f2' AS f2, NULL AS f3"];
    
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
    
    STAssertTrue([result numberOfTuples] > 3, @"Tuple count is not > 3 (is %d)!", [result numberOfTuples]);
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

- (void)testValue
{
    STAssertEqualObjects([_result valueAtRow:0 column:1], @"f2", @"value does not match (is %@)", [_result valueAtRow:0 column:1]);
}

- (void)testNullValue
{
    STAssertEquals([_result hasNullValueAtRow:0 column:2], YES, @"Column 2 is not null!");
}

- (void)testKindOfCommand
{
    STAssertEqualObjects([_result kindOfCommand], @"SELECT", @"kindOfCommand != SELECT (is %@)", [_result kindOfCommand]);
}

- (void)testAffectedRows
{
    // not using standard statement
    STNPostgreSQLStatement *statement = [STNPostgreSQLStatement statementWithConnection:_conn
                                                                           andStatement:@"INSERT INTO test VALUES (4711, 'Simon')"];
    NSError *error;
    STAssertTrue([statement execute:&error], @"Statement couldn't be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    
    STNPostgreSQLResult *result = [statement result];
    STAssertEquals([result numberOfAffectedRows], 1, @"Affected Rows != 1 (is %d)", [result numberOfAffectedRows]);
}
    

@end
