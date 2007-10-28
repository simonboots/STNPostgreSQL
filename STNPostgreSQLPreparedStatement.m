//
//  STNPostgreSQLPreparedStatement.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 28.09.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id: STNPostgreSQLPreparedStatement.m 40 2007-05-23 18:59:27Z sst $
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

#import "STNPostgreSQLPreparedStatement.h"

@implementation STNPostgreSQLPreparedStatement

#pragma mark initializers/dealloc

+ (STNPostgreSQLPreparedStatement *)statement
{
    return [[[self alloc] init] autorelease];
}

+ (STNPostgreSQLPreparedStatement *)statementWithConnection:(STNPostgreSQLConnection *)connection
{
    return [[[self alloc] initWithConnection:connection] autorelease];
}

+ (STNPostgreSQLPreparedStatement *)statementWithStatement:(NSString *)statement
{
    STNPostgreSQLPreparedStatement *_statement = [self statement];
    [_statement setStatement:statement];
    return _statement;
}

+ (STNPostgreSQLPreparedStatement *)statementWithConnection:(STNPostgreSQLConnection *)connection 
                                               andStatement:(NSString *)statement
{
    STNPostgreSQLPreparedStatement *_statement = [self statement];
    [_statement setStatement:statement];
    return _statement;
}


+ (STNPostgreSQLPreparedStatement *)statementWithStatement:(NSString *)statement
                                             andParameters:(NSArray *)parameters
{
    STNPostgreSQLPreparedStatement *_statement = [self statementWithStatement:statement];
    [_statement setParameters:parameters];
    return _statement;
}

+ (STNPostgreSQLPreparedStatement *)statementWithConnection:(STNPostgreSQLConnection *)connection
                                               andStatement:(NSString *)statement 
                                              andParameters:(NSArray *)parameters
{
    STNPostgreSQLPreparedStatement *_statement = [self statementWithConnection:connection
                                                                  andStatement:statement];
    [_statement setParameters:parameters];
    return _statement;
}

- (id)initWithConnection:(STNPostgreSQLConnection *)connection
{
    self = [super initWithConnection:connection];
    if (self != nil) {
        _statementName = nil;
        _parameterTypes = nil;
        _state = STNPostgreSQLPreparedStatePrepare;
    }
    
    return self;    
}

- (id)init {
    return [self initWithConnection:nil];
}

- (void) dealloc {
    [_statementName release];
    [_parameterTypes release];
    [super dealloc];
}

- (BOOL)prepare:(NSError **)error
{
    _state = STNPostgreSQLPreparedStatePrepare;
    
    if ([self execute:error]) {
        _state = STNPostgreSQLPreparedStateExecute;
        return YES;
    }
    
    return NO;
} 

#pragma mark statement preparation/execution

- (PGresult *)PQexecute
{    
    STNPostgreSQLConnection *connection = [self primaryConnection];
    PGresult *result = NULL;
    struct STNPostgreSQLRawParameterArray rawArray = [self buildRawParameterArray];
    
    if (connection == nil) {
        NSException *noConnectionException = [NSException exceptionWithName:@"noConnectionException"
                                                                     reason:@"No Connection Available"
                                                                   userInfo:nil];
        [noConnectionException raise];
    }
    
    
    if (_state == STNPostgreSQLPreparedStatePrepare) {
        result = PQprepare([connection PgConn],
                           [[self identifier] cStringUsingEncoding:NSASCIIStringEncoding],
                           [[self statement] cStringUsingEncoding:NSASCIIStringEncoding],
                           [[self parameters] count],
                           rawArray.types);
    } else {
        result = PQexecPrepared([connection PgConn],
                                [[self identifier] cStringUsingEncoding:NSASCIIStringEncoding],
                                [[self parameters] count],
                                (const char* const *)rawArray.values,
                                rawArray.lengths,
                                rawArray.formats,
                                0);
    }    
    
    
    free(rawArray.values);
    free(rawArray.types);
    free(rawArray.lengths);
    free(rawArray.formats);
    return result;
}

@end
