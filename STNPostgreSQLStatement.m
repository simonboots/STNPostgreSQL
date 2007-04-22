//
//  STNPostgreSQLStatement.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 01.04.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import "STNPostgreSQLStatement.h"

@implementation STNPostgreSQLStatement

+ (STNPostgreSQLStatement *)statement
{
    return [[[self alloc] init] autorelease];
}

+ (STNPostgreSQLStatement *)statementWithConnection:(STNPostgreSQLConnection *)connection
{
    return [[[self alloc] initWithConnection:connection] autorelease];
}

+ (STNPostgreSQLStatement *)statementWithStatement:(NSString *)statement
{
    STNPostgreSQLStatement *_statement = [[self alloc] init];
    [_statement setStatement:statement];
    return [_statement autorelease];
}

+ (STNPostgreSQLStatement *)statementWithConnection:(STNPostgreSQLConnection *)connection andStatement:(NSString *)statement
{
    STNPostgreSQLStatement *_statement = [[self alloc] initWithConnection:connection];
    [_statement setStatement:statement];
    return [_statement autorelease];
}

- (id)initWithConnection:(STNPostgreSQLConnection *)connection {
    self = [super init];
    if (self != nil) {
        [self setConnection:connection];
        [self setStatement:[NSString string]];
    }
    return self;
}

- (id) init {
    return [self initWithConnection:nil];
}

#pragma mark Getters/Setters

- (void)setStatement:(NSString *)statement
{
    if (statement != [self statement]) {
        [_statement release];
        _statement = [statement copy];
    }
}
    
- (NSString *)statement
{
    return _statement;
}

- (void)setConnection:(STNPostgreSQLConnection *)connection
{
    if (connection != [self connection]) {
        [_connection release];
        _connection = [connection retain];
    }
}

- (STNPostgreSQLConnection *)connection
{
    return _connection;
}

- (void)setDelegate:(id)delegate
{
    if (delegate != [self delegate]) {
        [_delegate release];
        _delegate = [delegate retain];
    }
}

- (id)delegate
{
    return _delegate;
}

#pragma mark Execution methods

- (BOOL)execute:(NSError **)error
{
    PGresult *result;
    ExecStatusType statusType;
    NSDictionary *userInfo;
    STNPostgreSQLErrorField *errorField;
    NSString *errorMessage;
    BOOL success;
    
    result = PQexec([[self connection] PgConn] , [[self statement] cStringUsingEncoding:NSASCIIStringEncoding]);
    statusType = PQresultStatus(result);
    
    errorMessage = [NSString stringWithUTF8String:PQresultErrorMessage(result)];
    errorField = [self generateErrorField:result];
    userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:errorMessage, errorField, nil]
                                           forKeys:[NSArray arrayWithObjects:@"errormessage", @"errorfield", nil]];

    switch (statusType) {
    case PGRES_EMPTY_QUERY:
        // The string sent to the server was empty.
        *error = [NSError errorWithDomain:STNPostgreSQLErrorDomain code:STNPostgreSQLEmptyQueryError userInfo:userInfo];
        success = NO;
        break;
    case PGRES_COMMAND_OK:
        // Successful completion of a command returning no data.
        *error = nil;
        success = YES;
        break;
    case PGRES_TUPLES_OK:
        // Successful completion of a command returning data (such as a SELECT or SHOW).
        *error = nil;
        success = YES;
        break;
    case PGRES_COPY_OUT:
        // Copy Out (from server) data transfer started.
        *error = nil;
        success = YES;
        break;
    case PGRES_COPY_IN:
        // Copy In (to server) data transfer started.
        *error = nil;
        success = YES;
        break;
    case PGRES_BAD_RESPONSE:
        // The server’s response was not understood.
        *error = [NSError errorWithDomain:STNPostgreSQLErrorDomain code:STNPostgreSQLBadResponseError userInfo:userInfo];
        success = NO;
        break;
    case PGRES_FATAL_ERROR:
        // A fatal error occurred.
        *error = [NSError errorWithDomain:STNPostgreSQLErrorDomain code:STNPostgreSQLStatementFatalError userInfo:userInfo];
        success = NO;
        break;
    default:
        break;
    }

    return success;
}

- (void)startExecution
{
    // call delegate
    if ([_delegate respondsToSelector:@selector(executionAttemptShouldStart)]) {
        if ([_delegate executionAttemptShouldStart] == NO) {
            return;
        }
    }
    
    // start thread
    [NSThread detachNewThreadSelector:@selector(executeWithDelegateCalls:) toTarget:self withObject:self];
}

- (void)executeWithDelegateCalls:(id)param
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSError *error;
    BOOL success;
    
    // call delegate
    if ([_delegate respondsToSelector:@selector(executionAttemptWillStart)]) {
        [_delegate executionAttemptWillStart];
    }
    
    success = [param execute:&error];
    
    // call delegate
    if ([_delegate respondsToSelector:@selector(executionAttemptEnded:error:)]) {
        [_delegate executionAttemptEnded:success error:error];
        NSLog(@"executionAttempt called by object");
    }
    
    [pool release];
    
    return;
}

#pragma mark Error handling

- (STNPostgreSQLErrorField *)generateErrorField:(PGresult *)result
{
    STNPostgreSQLErrorField *errorField =[[STNPostgreSQLErrorField alloc] initWithPGResult:result];
    return [errorField autorelease];
}


- (void) dealloc {
    [[self connection] release];
    [[self statement] release];
    [super dealloc];
}


@end
