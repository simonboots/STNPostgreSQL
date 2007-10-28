//
//  STTPostgreSQLPreparedStatementTests.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 10/28/07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id: STTPostgreSQLParameteredStatementTests.m 40 2007-05-23 18:59:27Z sst $
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

#import "STTPostgreSQLPreparedStatementTests.h"


@implementation STTPostgreSQLPreparedStatementTests

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
}

- (void)testValidStatement
{
    STNPostgreSQLPreparedStatement *statement = [[STNPostgreSQLPreparedStatement alloc] init];
    [statement setConnection:_conn];
    
    [statement setStatement:@"INSERT INTO stnpostgresqltests VALUES($1, $2)"];
    [statement addParameterWithValue:@"17" type:@"int8"];
    [statement addParameterWithValue:@"seventeen" type:@"varchar"];
    
    NSError *error;
    
    //STAssertTrue([statement prepare:&error], @"Statement should prepare (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    
    STAssertTrue([statement execute:&error], @"Statement should be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    [statement release];
}

- (void)tearDown
{
    [_conn disconnect];
    [_conn release];
}

@end
