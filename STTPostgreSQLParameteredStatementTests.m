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
    [statement addParameterWithValue:@"4712" type:@"int8"];
    [statement addParameterWithValue:@"SimonSt" type:@"varchar"];
    
    NSError *error;
    
    STAssertTrue([statement execute:&error], @"Statement should be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    [statement release];
}

- (void)testInvalidStatement
{
    STNPostgreSQLParameteredStatement *statement = [[STNPostgreSQLParameteredStatement alloc] init];
    [statement setConnection:_conn];
    
    [statement setStatement:@"INSERT INTO test VALUES($1, $2)"];
    [statement addParameterWithValue:@"4712" type:@"int8"];
    
    NSError *error;
    
    STAssertFalse([statement execute:&error], @"Statement shouldn't be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    [statement release];
}

- (void)testWithSeparateParameter
{
    STNPostgreSQLParameteredStatement *statement = [[STNPostgreSQLParameteredStatement alloc] init];
    [statement setConnection:_conn];
    
    [statement setStatement:@"INSERT INTO test VALUES($1, $2)"];
    [statement addParameterWithValue:@"4713" type:@"int8"];
    
    // separate parameter
    
    // STNPostgreSQLStatementParameter doesn't support NSString datatypes yet
    unsigned int varchartype = [[_conn availableTypes] oidForType:@"varchar"];
    STNPostgreSQLStatementParameter *param = [STNPostgreSQLStatementParameter parameterWithValue:@"A Value" 
                                                                                        datatype:varchartype];
    
    [statement addParameter:param];
    
    NSError *error;
    
    STAssertTrue([statement execute:&error], @"Statement should be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    [statement release];
}

- (void)testWithSeparateBinaryParameter
{
    char binaryValue[] = {'H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd'};
    NSData *binaryData = [NSData dataWithBytes:binaryValue length:11];
    
    STNPostgreSQLParameteredStatement *statement =[[STNPostgreSQLParameteredStatement alloc] init];
    [statement setConnection:_conn];
    
    [statement setStatement:@"INSERT INTO test VALUES($1, $2)"];
    [statement addParameterWithValue:@"4714" type:@"int8"];
    
    // binary parameter
    unsigned int varchartype = [[_conn availableTypes] oidForType:@"varchar"];
    STNPostgreSQLStatementParameter *binaryParameter = [STNPostgreSQLStatementParameter parameterWithBinaryValue:binaryData
                                                                                                        datatype:varchartype];
    [statement addParameter:binaryParameter];
    
    NSError *error;
    
    STAssertTrue([statement execute:&error], @"Statement should be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    [statement release];
    
}
    

- (void)tearDown
{
    [_conn disconnect];
    [_conn release];
}

@end
