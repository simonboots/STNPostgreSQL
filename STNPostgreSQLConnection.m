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
    }
    return self;
}

- (void)setAuthType:(NSString *)authType
{
    [[_connectionattributes objectForKey:@"authtype"] release];
    [_connectionattributes setValue:authType forKey:@"authtype"];
}

- (NSString *)authType
{
    return [_connectionattributes objectForKey:@"authtype"];
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
    [[_connectionattributes objectForKey:@"hostaddr"] release];
    [_connectionattributes setValue:hostaddress forKey:@"hostaddr"];
}

- (NSString *)hostAddress
{
    return [_connectionattributes objectForKey:@"hostaddr"];
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
    [[_connectionattributes objectForKey:@"dbname"] release];
    [_connectionattributes setValue:databasename forKey:@"dbname"];
}

- (NSString *)databaseName
{
    return [_connectionattributes objectForKey:@"dbname"];
}

- (void)setUser:(NSString *)user
{
    [[_connectionattributes objectForKey:@"user"] release];
    [_connectionattributes setValue:user forKey:@"user"];
}

- (NSString *)user
{
    return [_connectionattributes objectForKey:@"user"];
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

- (void)setConnectTimeout:(NSNumber *)seconds
{
    [[_connectionattributes objectForKey:@"connect_timeout"] release];
    [_connectionattributes setValue:seconds forKey:@"connect_timeout"];
}

- (NSNumber *)connectionTimeout
{
    return [_connectionattributes objectForKey:@"connect_timeout"];
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

- (NSString *)connectionString
{
    NSMutableString *connectionstring = [[NSMutableString alloc] initWithString:@""];
    NSString *key;
    id value;
    NSEnumerator *csenum;
    
    csenum = [_connectionattributes keyEnumerator];
    while (key = [csenum nextObject]) {
        value = [_connectionattributes objectForKey:key];
        
        if ([value length] == 0) {
            value = @"''";
        }
        
        [connectionstring appendFormat:@"%@=%@ ", key, value];
    }
    
    return connectionstring;
}

- (BOOL)connect:(NSError **)error
{
    NSDictionary *userinfo;
    ConnStatusType status;
    
    _pgconn = PQconnectdb([[self connectionString] cStringUsingEncoding:NSASCIIStringEncoding]);
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
