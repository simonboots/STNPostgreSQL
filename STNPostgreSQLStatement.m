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
#import "STNPostgreSQLErrorDomain.h"

@implementation STNPostgreSQLStatement

#pragma mark initializers/dealloc

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
        _delegate = nil;
        _result = nil;
        _temporaryConnection = nil;
        [self setConnection:connection];
        [self setStatement:[NSString string]];
    }
    return self;
}

- (id) init {
    return [self initWithConnection:nil];
}

- (void)dealloc
{    
    [[self connection] release];
    [[self statement] release];
    [[self result] release];
    [[self delegate] release];
    [super dealloc];
}


#pragma mark getters/setters

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

- (STNPostgreSQLConnection *)primaryConnection
{
    if (_temporaryConnection != nil) {
        return _temporaryConnection;
    } else {
        return [self connection];
    }
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

#pragma mark execution methods

- (PGresult *)PQexecute
{
    PGresult *result;
    STNPostgreSQLConnection *connection = [self primaryConnection];
    
    if (connection == nil) {
        NSException *noConnectionException = [NSException exceptionWithName:@"noConnectionException"
                                                                     reason:@"No Connection Available"
                                                                   userInfo:nil];
        [noConnectionException raise];
    }
    
    if (! [connection isConnected]) {
        NSException *notConnectedException = [NSException exceptionWithName:@"notConnectedException"
                                                                     reason:@"Not connected"
                                                                   userInfo:nil];
        [notConnectedException raise];
    }

    result = PQexec([connection PgConn] , [[self statement] cStringUsingEncoding:NSASCIIStringEncoding]);
    
    // reset temporary connection
    if (_temporaryConnection != nil)
    {
        [_temporaryConnection release];
        _temporaryConnection = nil;
    }
    
    return result;
}

- (BOOL)execute:(NSError **)error
{
    [_result release];
    _result = nil; // reset result object
    PGresult *result;
    ExecStatusType statusType;
    NSDictionary *userInfo;
    STNPostgreSQLErrorField *errorField;
    NSString *errorMessage;
    BOOL success;
    
    @try {
        result = [self PQexecute];
    } @catch(NSException *e) {
        errorMessage = [e reason];
        userInfo = [NSDictionary dictionaryWithObject:errorMessage forKey:@"errormessage"];
        if ([[e name] isEqualToString:@"notConnectedException"]) {
            *error = [NSError errorWithDomain:STNPostgreSQLErrorDomain
                                         code:STNPostgreSQLNotConnected
                                     userInfo:userInfo];
        } else if ([[e name] isEqualToString:@"noConnectionException"]) {
            *error = [NSError errorWithDomain:STNPostgreSQLErrorDomain
                                         code:STNPostgreSQLNoConnection
                                     userInfo:userInfo];
        } else {
            *error = nil;
        }
        return NO;
    }
        
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
    
    if (success) {
        // Build STNPostgreSQLResult object
        _result = [[STNPostgreSQLResult alloc] initWithPGresult:result];
    }

    return success;
}

- (BOOL)executeWithConnection:(STNPostgreSQLConnection *)connection error:(NSError **)error
{
    _temporaryConnection = [connection retain];
    return [self execute:error];
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

- (void)startExecutionWithConnection:(STNPostgreSQLConnection *)connection
{
    _temporaryConnection = [connection retain];
    [self startExecution];
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

#pragma mark result handling

- (STNPostgreSQLResult *)result
{
    return _result;
}

#pragma mark error handling

- (STNPostgreSQLErrorField *)generateErrorField:(PGresult *)result
{
    STNPostgreSQLErrorField *errorField =[[STNPostgreSQLErrorField alloc] initWithPGResult:result];
    return [errorField autorelease];
}




@end
