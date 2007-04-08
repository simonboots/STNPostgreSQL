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

#pragma mark Execution methods

- (BOOL)execute:(NSError **)error
{
    PGresult *result;
    ExecStatusType statusType;
    NSDictionary *userInfo;
    NSDictionary *errorField;
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

#pragma mark Error handling

- (NSDictionary *)generateErrorField:(PGresult *)result
{
    NSArray *keys = [NSArray arrayWithObjects:@"severity", @"sqlstate", @"message_primary", @"message_detail", @"message_hint",
                                              @"statement_position", @"internal_position", @"internal_query", @"context",
                                              @"source_file", @"source_line", @"source_function", nil];
    
    int fieldcodes[] = {PG_DIAG_SEVERITY, PG_DIAG_SQLSTATE, PG_DIAG_MESSAGE_PRIMARY, PG_DIAG_MESSAGE_DETAIL, PG_DIAG_MESSAGE_HINT, PG_DIAG_STATEMENT_POSITION, PG_DIAG_INTERNAL_POSITION, PG_DIAG_INTERNAL_QUERY, PG_DIAG_CONTEXT, PG_DIAG_SOURCE_FILE, PG_DIAG_SOURCE_LINE, PG_DIAG_SOURCE_FUNCTION};
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    int i;
    for (i = 0; i < sizeof(fieldcodes)/sizeof(int); i++) {
        char *errorField = PQresultErrorField(result,fieldcodes[i]);
        if (errorField == NULL) {
            [values addObject:[NSString string]];
        } else {
            [values addObject:[NSString stringWithUTF8String:errorField]];
        }
    }
    
    [values autorelease];
    
    return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}


- (void) dealloc {
    [[self connection] release];
    [[self statement] release];
    [super dealloc];
}


@end
