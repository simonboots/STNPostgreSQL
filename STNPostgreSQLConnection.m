//
//  STNPostgreSQLConnection.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 16.10.06.
//  Copyright 2006 stiefels.net. All rights reserved.
//
//  $Id$
//

#import "STNPostgreSQLConnection.h"
#import "STNPostgreSQLErrorDomain.h"

@implementation STNPostgreSQLConnection

- (id)init {
    self = [super init];
    if (self != nil) {
        // ivar initialisation
        _connectionattributes = [[NSMutableDictionary alloc] init];
        
        // default values for connection attributes
        PQconninfoOption *connectionoptions, *connectionoptionsanchor;
        connectionoptions = connectionoptionsanchor = PQconndefaults();
        
        while (connectionoptions->keyword != NULL) {
            
            // val element has to be set
            char *defaultvalue;
            
            // preset rawvalue if not set
            if (connectionoptions->val != 0) {
                defaultvalue = connectionoptions->val;
            } else {
                defaultvalue = "";
            }
            
            NSLog(@"%s\n", connectionoptions->keyword);
            
            [_connectionattributes setObject:[NSString stringWithCString:defaultvalue encoding:NSASCIIStringEncoding] forKey:[NSString stringWithCString:connectionoptions->keyword encoding:NSASCIIStringEncoding]];
            
            // next array element
            connectionoptions++;
        }
        
        // free allocated space
        PQconninfoFree(connectionoptionsanchor);
        
        // remove service name (causes error if set to empty string)
        [self setService:nil];
    }
    return self;
}

#pragma mark Getters/Setters

- (void)setAuthType:(NSString *)authType
{
    [_connectionattributes setValue:authType forKey:@"authtype"];
}

- (NSString *)authType
{
    return [_connectionattributes objectForKey:@"authtype"];
}

- (void)setHost:(NSString *)host
{
    [_connectionattributes setValue:host forKey:@"host"];
}

- (NSString *)host
{
    return [_connectionattributes objectForKey:@"host"];
}

- (void)setHostAddress:(NSString *)hostaddress
{
    [_connectionattributes setValue:hostaddress forKey:@"hostaddr"];
}

- (NSString *)hostAddress
{
    return [_connectionattributes objectForKey:@"hostaddr"];
}

- (void)setPort:(NSString *)port
{
    [_connectionattributes setValue:port forKey:@"port"];
}

- (NSString *)port
{
    return [_connectionattributes objectForKey:@"port"];
}

- (void)setDatabaseName:(NSString *)databasename
{
    [_connectionattributes setValue:databasename forKey:@"dbname"];
}

- (NSString *)databaseName
{
    return [_connectionattributes objectForKey:@"dbname"];
}

- (void)setUser:(NSString *)user
{
    [_connectionattributes setValue:user forKey:@"user"];
}

- (NSString *)user
{
    return [_connectionattributes objectForKey:@"user"];
}

- (void)setPassword:(NSString *)password
{
    [_connectionattributes setValue:password forKey:@"password"];
}

- (NSString *)password
{
    return [_connectionattributes objectForKey:@"password"];
}

- (void)setConnectTimeout:(NSNumber *)seconds
{
    [_connectionattributes setValue:seconds forKey:@"connect_timeout"];
}

- (NSNumber *)connectionTimeout
{
    return [_connectionattributes objectForKey:@"connect_timeout"];
}

- (void)setCommandLineOptions:(NSString *)options
{
    [_connectionattributes setValue:options forKey:@"options"];
}

- (NSString *)commandLineOptions
{
    return [_connectionattributes objectForKey:@"options"];
}

- (void)setSSLMode:(STNPostgreSQLConnectionSSLMode)sslmode
{
    //[[_connectionattributes objectForKey:@"sslmode"] release];
    NSString *mode;

    switch (sslmode) {
    case STNPostgreSQLConnectionSSLModeAllow:
        mode = @"allow";
        break;
    case STNPostgreSQLConnectionSSLModeDisable:
        mode = @"disable";
        break;
    case STNPostgreSQLConnectionSSLModePrefer:
        mode = @"prefer";
        break;
    case STNPostgreSQLConnectionSSLModeRequire:
        mode = @"require";
        break;
    default:
        // default value
        mode = @"prefer";
        break;
    }
    
    [_connectionattributes setValue:mode forKey:@"sslmode"];
}

- (STNPostgreSQLConnectionSSLMode)SSLMode
{
    NSString *mode = [_connectionattributes objectForKey:@"sslmode"];
    if ([mode isEqualToString:@"allow"]) {
        return STNPostgreSQLConnectionSSLModeAllow;
    } else if ([mode isEqualToString:@"disable"]) {
        return STNPostgreSQLConnectionSSLModeDisable;
    } else if ([mode isEqualToString:@"prefer"]) {
        return STNPostgreSQLConnectionSSLModePrefer;
    } else if ([mode isEqualToString:@"require"]) {
        return STNPostgreSQLConnectionSSLModeRequire;
    } else {
        // default value
        return STNPostgreSQLConnectionSSLModePrefer;
    }
}

//- (void)setKerberosServiceName:(NSString *)servicename
//{
//    [[_connectionattributes objectForKey:@"krbservicename"] release];
//    [_connectionattributes setValue:servicename forKey:@"krbservicename"];
//}
//
//- (NSString *)kerberosServiceName
//{
//    return [_connectionattributes objectForKey:@"krbservicename"];
//}

- (void)setService:(NSString *)service
{
    [_connectionattributes setValue:service forKey:@"service"];
}

- (NSString *)service
{
    return [_connectionattributes objectForKey:@"service"];
}

- (void)setDelegate:(id)delegate
{
    [_delegate release];
    _delegate = [delegate retain];
}

- (id)delegate
{
    return _delegate;
}

- (PGconn *)PgConn
{
    return _pgconn;
}

#pragma mark connection strings methods

- (NSString *)connectionString
{
    NSMutableString *connectionstring = [[NSMutableString alloc] initWithString:@""];
    NSString *key;
    id value;
    NSEnumerator *csenum;
    
    csenum = [_connectionattributes keyEnumerator];
    while (key = [csenum nextObject]) {
        value = [self escapeParameterValue:[_connectionattributes objectForKey:key]];
        
        if ([value length] == 0) {
            value = @"''";
        }
        
        [connectionstring appendFormat:@"%@=%@ ", key, value];
    }
    
    return connectionstring;
}

- (NSString *)escapeParameterValue:(NSString *)value
{
    // characters to escape: "\", "'"
    unsigned int length = [value length];
    unsigned int c;
    NSMutableString *escapedValue = [[NSMutableString alloc] initWithString:@""];
    
    for (c = 0; c < length; c++) {
        unichar character = [value characterAtIndex:c];
        
        if (character == '\\' || character == '\'') {
            [escapedValue appendString:@"\\"];
        }
        
        [escapedValue appendFormat:@"%c", character];
    }
    
    return [escapedValue autorelease];
}

#pragma mark connect methods

- (BOOL)connect:(NSError **)error
{
    NSDictionary *userinfo;
    ConnStatusType status;
    
    _pgconn = PQconnectdb([[self connectionString] cStringUsingEncoding:NSASCIIStringEncoding]);
    status = PQstatus(_pgconn);
    
    if (status != CONNECTION_OK) {
        userinfo = [NSDictionary dictionaryWithObject:[self recentErrorMessage] forKey:@"errormessage"];
        *error = [NSError errorWithDomain:STNPostgreSQLErrorDomain code:STNPostgreSQLConnectionError userInfo:userinfo];
        return NO;
    }
    
    *error = nil;
    return YES;
}
        
- (void)startConnection
{
    // call delegate
    if ([_delegate respondsToSelector:@selector(connectionAttemptShouldStart)]) {
        if ([_delegate connectionAttemptShouldStart] == NO) {
            return;
        }
    }
    
    // start thread
    [NSThread detachNewThreadSelector:@selector(connectWithDelegateCalls:) toTarget:self withObject:self];
}

- (void)connectWithDelegateCalls:(id)param
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSError *error;
    BOOL success;
    
    // call delegate
    if ([_delegate respondsToSelector:@selector(connectionAttemptWillStart)]) {
        [_delegate connectionAttemptWillStart];
    }
    
    success = [param connect:&error];
    
    // call delegate
    if ([_delegate respondsToSelector:@selector(connectionAttemptEnded:error:)]) {
        [_delegate connectionAttemptEnded:success error:error];
        NSLog(@"connectionAttempt called by object");
    }
    
    [pool release];
    
    return;
}

- (void)disconnect
{
    PQfinish(_pgconn);
}

- (BOOL)reconnect:(NSError **)error
{
    [self disconnect];
    return [self connect:error];
}

- (void)startReconnection
{
    [self disconnect];
    [self startConnection];
}

#pragma mark connection status methods

- (BOOL)isConnected
{
    return PQstatus(_pgconn) == CONNECTION_OK ? YES : NO;
}

- (NSDictionary *)serverInformation
{
    NSNumber *versionnumber = [NSNumber numberWithInt:PQserverVersion(_pgconn)];
    NSNumber *protocolversion = [NSNumber numberWithInt:PQprotocolVersion(_pgconn)];
    NSNumber *backendPID = [NSNumber numberWithInt:PQbackendPID(_pgconn)];
    
    // build formatted version number
    int major = 0, minor = 0, service = 0;
    major = [versionnumber intValue] / 10000;
    minor = ([versionnumber intValue] - major * 10000) / 100;
    service = [versionnumber intValue] - major * 10000 - minor * 100;
    NSString *formattedVersionNumber = [NSString stringWithFormat:@"%d.%d.%d", major, minor, service];
    
    NSArray *keys = [NSArray arrayWithObjects:@"versionnumber", @"formattedversionnumber", @"protocolversion", @"backendPID", nil];
    NSArray *values = [NSArray arrayWithObjects:versionnumber, formattedVersionNumber, protocolversion, backendPID, nil];
    
    return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}

- (BOOL)parameteredStatementAvailable
{
    if ([[[self serverInformation] objectForKey:@"protocolversion"] isEqualToNumber:[NSNumber numberWithInt:PROTOCOLVERSION_PARAM_STATEMENT]]) {
        return YES;
    }
    return NO;
}

- (BOOL)preparedStatementsAvailable
{
    if ([[[self serverInformation] objectForKey:@"protocolversion"] isEqualToNumber:[NSNumber numberWithInt:PROTOCOLVERSION_PREP_STATEMENT]]) {
        return YES;
    }
    return NO;
}

- (NSString *)recentErrorMessage
{
    return [NSString stringWithCString:PQerrorMessage(_pgconn) encoding:NSASCIIStringEncoding];
}

@end
