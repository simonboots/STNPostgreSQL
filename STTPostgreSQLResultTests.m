//
//  STTPostgreSQLResultTests.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 03.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id: STTPostgreSQLResultTests.m 39 2007-05-23 18:35:40Z sst 
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
    [statement setStatement:@"SELECT * FROM stnpostgresqltests"];
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
    
    [statement setStatement:@"SELECT name FROM stnpostgresqltests"];
    
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
                                                                           andStatement:@"INSERT INTO stnpostgresqltests VALUES (10, 'ten')"];
    NSError *error;
    STAssertTrue([statement execute:&error], @"Statement couldn't be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    
    STNPostgreSQLResult *result = [statement result];
    STAssertEquals([result numberOfAffectedRows], 1, @"Affected Rows != 1 (is %d)", [result numberOfAffectedRows]);
}
    

@end
