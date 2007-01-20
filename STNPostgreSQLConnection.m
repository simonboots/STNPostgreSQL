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
            char *value;
            if (connectionoptions->val != 0) {
                value = connectionoptions->val;
            } else {
                value = "";
            }
                        
            [_connectionattributes setObject:[NSString stringWithCString:value encoding:NSASCIIStringEncoding] forKey:[NSString stringWithCString:connectionoptions->keyword encoding:NSASCIIStringEncoding]];
            connectionoptions++;
        }
        
        // free allocated space
        PQconninfoFree(connectionoptionsanchor);
    }
    return self;
}


- (void)setHost:(NSString *)host
{
    [[_connectionattributes objectForKey:@"host"] release];
    [_connectionattributes setValue:host forKey:@"host"];
}

- (NSString *)host
{
    return [_connectionattributes objectForKey:@"host"];
}

- (void)setHostAddress:(NSString *)hostaddress
{
    [[_connectionattributes objectForKey:@"hostaddress"] release];
    [_connectionattributes setValue:hostaddress forKey:@"hostaddress"];
}

- (NSString *)hostAddress
{
    return [_connectionattributes objectForKey:@"hostaddress"];
}

- (void)setPort:(NSString *)port
{
    [[_connectionattributes objectForKey:@"port"] release];
    [_connectionattributes setValue:port forKey:@"port"];
}

- (NSString *)port
{
    return [_connectionattributes objectForKey:@"port"];
}

- (void)setDatabaseName:(NSString *)databasename
{
    [[_connectionattributes objectForKey:@"databasename"] release];
    [_connectionattributes setValue:databasename forKey:@"databasename"];
}

- (NSString *)databaseName
{
    return [_connectionattributes objectForKey:@"databasename"];
}

- (void)setUserName:(NSString *)username
{
    [[_connectionattributes objectForKey:@"username"] release];
    [_connectionattributes setValue:username forKey:@"username"];
}

- (NSString *)userName
{
    return [_connectionattributes objectForKey:@"username"];
}

- (void)setPassword:(NSString *)password
{
    [[_connectionattributes objectForKey:@"password"] release];
    [_connectionattributes setValue:password forKey:@"password"];
}

- (NSString *)password
{
    return [_connectionattributes objectForKey:@"password"];
}

- (void)setConnectionTimeout:(NSNumber *)seconds
{
    [[_connectionattributes objectForKey:@"timeout"] release];
    [_connectionattributes setValue:seconds forKey:@"timeout"];
}

- (NSNumber *)connectionTimeout
{
    return [_connectionattributes objectForKey:@"timeout"];
}

- (void)setCommandLineOptions:(NSString *)options
{
    [[_connectionattributes objectForKey:@"options"] release];
    [_connectionattributes setValue:options forKey:@"options"];
}

- (NSString *)commandLineOptions
{
    return [_connectionattributes objectForKey:@"options"];
}

- (void)setSSLMode:(STNPostgreSQLConnectionSSLMode)sslmode
{
    [[_connectionattributes objectForKey:@"sslmode"] release];
    [_connectionattributes setValue:[NSNumber numberWithInt:(int)sslmode] forKey:@"sslmode"];
}

- (STNPostgreSQLConnectionSSLMode)SSLMode
{
    return (STNPostgreSQLConnectionSSLMode)[[_connectionattributes objectForKey:@"sslmode"] intValue];
}

- (void)setKerberosServiceName:(NSString *)servicename
{
    [[_connectionattributes objectForKey:@"krbservicename"] release];
    [_connectionattributes setValue:servicename forKey:@"krbservicename"];
}

- (NSString *)kerberosServiceName
{
    return [_connectionattributes objectForKey:@"krbservicename"];
}

- (void)setService:(NSString *)service
{
    [[_connectionattributes objectForKey:@"service"] release];
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

- (BOOL)connect:(NSError **)error
{
    NSMutableString *connectionstring = @"";
    NSString *key;
    NSEnumerator *csenum;
    NSDictionary *userinfo;
    ConnStatusType status;
    
    // build connection string
    csenum = [_connectionattributes keyEnumerator];
    while (key = [csenum nextObject]) {
        [connectionstring appendFormat:@"@=@ ", key, [_connectionattributes objectForKey:key]];
    }
    
    _pgconn = PQconnectdb([connectionstring cStringUsingEncoding:NSASCIIStringEncoding]);
    status = PQstatus(_pgconn);
    
    if (status != CONNECTION_OK) {
        userinfo = [NSDictionary dictionaryWithObject:[self recentErrorMessage] forKey:@"errormessage"];
        *error = [NSError errorWithDomain:STNPostgreSQLErrorDomain code:STNPostgreSQLConnectionFailed userInfo:userinfo];
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
    [NSThread detachNewThreadSelector:@selector(connectWithDelegateCalls) toTarget:self withObject:self];
}

- (void)connectWithDelegateCalls:(id)param
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool init] alloc];
    NSError *error;
    NSDictionary *userinfo;
    ConnStatusType status;
    BOOL success;
    
    // call delegate
    if ([_delegate respondsToSelector:@selector(connectionAttemptWillStart)]) {
        [_delegate connectionAttemptWillStart];
    }
    
    success = [param connect:&error];
    
    // call delegate
    if ([_delegate respondsToSelector:@selector(connectionAttemptEnded:error:)]) {
        [_delegate connectionAttemptEnded:success error:error];
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

- (BOOL)isConnected
{
    return PQstatus(_pgconn) == CONNECTION_OK ? YES : NO;
}


/*!
    @method     serverInformation
    @abstract   Returns useful information about the server and the connection
    @discussion method provides inforamtion in NSDictionary collection. The values are:
    Key: @"versionnumber" => NSString: Version number of server (e.g.: 8.1.4)
	Key: @"protocolversion" => NSNumber: Version number of protocol (e.g. 3)
	Key: @"backendPID" => NSNumber: Backend process ID of connection
    @result     dictionary with information
*/
- (NSDictionary *)serverInformation
{
    NSArray *keys = [NSArray arrayWithObjects:@"versionnumber", @"protocolversion", @"backendPID", nil];
    NSNumber *protocolversion = [NSNumber numberWithInt:PQprotocolVersion(_pgconn)];
    
    return nil;
}

/*!
    @method     parameteredStatementAvailable
    @abstract   Returns if parametered statements are available through connection
    @discussion Since parametered statements are only available in protocol version 3 or above you should check if the connection supports this feature.
    @result     YES if parametered statements are available, NO if not
*/
//- (BOOL)parameteredStatementAvailable;

/*!
    @method     preparedStatementsAvailable
    @abstract   Returns if prepared statements are available through connection
    @discussion Since parametered statements are only available in protocol version 3 or above you should check if the connection supports this feature.
    @result     YES if parametered statements are available, NO if not
*/
//- (BOOL)preparedStatementsAvailable;


/*!
    @method     recentErrorMessage
    @abstract   Returns the error message most recently generated by an operation on the connection.
    @result     most recent error message
*/
//- (NSString *)recentErrorMessage;

@end
