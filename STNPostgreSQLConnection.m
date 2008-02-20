//  STNPostgreSQLConnection.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 16.10.06.
//  Copyright 2006 stiefels.net. All rights reserved.
//
//  $Id$
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

#import "STNPostgreSQLConnection.h"
#import "STNPostgreSQLErrorDomain.h"
#import "STNPostgreSQLStatement.h"
#import "STNPostgreSQLTypes.h"

#pragma mark private methods

@interface STNPostgreSQLConnection (private)
- (void)connectThreaded:(id)param;
@end

@implementation STNPostgreSQLConnection

#pragma mark connection parameter constants

NSString *const STNPostgreSQLConnectionParameterHost = @"host";
NSString *const STNPostgreSQLConnectionParameterHostaddr = @"hostaddr";
NSString *const STNPostgreSQLConnectionParameterPort = @"port";
NSString *const STNPostgreSQLConnectionParameterDbname = @"dbname";
NSString *const STNPostgreSQLConnectionParameterUser = @"user";
NSString *const STNPostgreSQLConnectionParameterPassword = @"password";
NSString *const STNPostgreSQLConnectionParameterConnectTimeout = @"connect_timeout";
NSString *const STNPostgreSQLConnectionParameterOptions = @"options";
NSString *const STNPostgreSQLConnectionParameterTty = @"tty";
NSString *const STNPostgreSQLConnectionParameterSslmode = @"sslmode";
NSString *const STNPostgreSQLConnectionParameterKrbsrvname = @"krbsrvname";
NSString *const STNPostgreSQLConnectionParameterGsslib = @"gsslib";
NSString *const STNPostgreSQLConnectionParameterService = @"service";

#pragma mark ssl mode constants

NSString *const STNPostgreSQLConnectionSSLModeDisable = @"disable";
NSString *const STNPostgreSQLConnectionSSLModeAllow = @"allow";
NSString *const STNPostgreSQLConnectionSSLModePrefer = @"prefer";
NSString *const STNPostgreSQLConnectionSSLModeRequire = @"require";

#pragma mark server information constants

NSString *const STNPostgreSQLServerInfoVersionNumber = @"versionnumber";
NSString *const STNPostgreSQLServerInfoFormattedVersionNumber = @"formattedversionnumber";
NSString *const STNPostgreSQLServerInfoProtocolVersion = @"protocolversion";
NSString *const STNPostgreSQLServerInfoBackendPID = @"backendPID";
NSString *const STNPostgreSQLServerInfoServerEncoding = @"server_encoding";
NSString *const STNPostgreSQLServerInfoClientEncoding = @"client_encoding";
NSString *const STNPostgreSQLServerInfoIsSuperuser = @"is_superuser";
NSString *const STNPostgreSQLServerInfoSessionAuthorization = @"session_authorization";
NSString *const STNPostgreSQLServerInfoDateStyle = @"DateStyle";
NSString *const STNPostgreSQLServerInfoTimeZone = @"TimeZone";
NSString *const STNPostgreSQLServerInfoIntegerDatetimes = @"interger_datetimes";
NSString *const STNPostgreSQLServerInfoStandardConformingStrings = @"standard_conforming_strings";

#pragma mark misc internal constants

NSString *const STNPostgreSQLErrorMessageUserInfoKey = @"errormessage";
NSString *const STNPostgreSQLLoadDatatypesStatement = @"SELECT oid, typname FROM pg_catalog.pg_type WHERE substring(typname from 1 for 1) != '_'";
NSString *const STNPostgreSQLSetUTF8ClientEncodingStatement = @"SET client_encoding TO UTF8";

#pragma mark initializers/dealloc

+ (STNPostgreSQLConnection *)connection
{
    return [[[self alloc] init] autorelease];
}

- (id)init {
    self = [super init];
    if (self != nil) {
        // ivar initialisation
        _connectionattributes = [[NSMutableDictionary alloc] init];
        _delegate = nil;
        _pgconn = NULL;
        _datatypes = nil;
        
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
        connectionoptions = connectionoptionsanchor = NULL;
        
        // remove service name (causes error if set to empty string)
        [self setService:nil];
    }
    return self;
}

- (void)dealloc
{
    [self disconnect];
    [_connectionattributes release];
    [_datatypes release];
    [super dealloc];
}

#pragma mark getters/setters

- (void)setHost:(NSString *)host
{
    [_connectionattributes setValue:host forKey:STNPostgreSQLConnectionParameterHost];
}

- (NSString *)host
{
    return [_connectionattributes objectForKey:STNPostgreSQLConnectionParameterHost];
}

- (void)setHostAddress:(NSString *)hostaddress
{
    [_connectionattributes setValue:hostaddress forKey:STNPostgreSQLConnectionParameterHostaddr];
}

- (NSString *)hostAddress
{
    return [_connectionattributes objectForKey:STNPostgreSQLConnectionParameterHostaddr];
}

- (void)setPort:(NSString *)port
{
    [_connectionattributes setValue:port forKey:STNPostgreSQLConnectionParameterPort];
}

- (NSString *)port
{
    return [_connectionattributes objectForKey:STNPostgreSQLConnectionParameterPort];
}

- (void)setDatabaseName:(NSString *)databasename
{
    [_connectionattributes setValue:databasename forKey:STNPostgreSQLConnectionParameterDbname];
}

- (NSString *)databaseName
{
    return [_connectionattributes objectForKey:STNPostgreSQLConnectionParameterDbname];
}

- (void)setUser:(NSString *)user
{
    [_connectionattributes setValue:user forKey:STNPostgreSQLConnectionParameterUser];
}

- (NSString *)user
{
    return [_connectionattributes objectForKey:STNPostgreSQLConnectionParameterUser];
}

- (void)setPassword:(NSString *)password
{
    [_connectionattributes setValue:password forKey:STNPostgreSQLConnectionParameterPassword];
}

- (NSString *)password
{
    return [_connectionattributes objectForKey:STNPostgreSQLConnectionParameterPassword];
}

- (void)setConnectTimeout:(NSNumber *)seconds
{
    [_connectionattributes setValue:seconds forKey:STNPostgreSQLConnectionParameterConnectTimeout];
}

- (NSNumber *)connectTimeout
{
    return [_connectionattributes objectForKey:STNPostgreSQLConnectionParameterConnectTimeout];
}

- (void)setCommandLineOptions:(NSString *)options
{
    [_connectionattributes setValue:options forKey:STNPostgreSQLConnectionParameterOptions];
}

- (NSString *)commandLineOptions
{
    return [_connectionattributes objectForKey:STNPostgreSQLConnectionParameterOptions];
}

- (void)setSSLMode:(NSString *)sslmode
{
    [_connectionattributes setValue:sslmode forKey:STNPostgreSQLConnectionParameterSslmode];
}

- (NSString *)SSLMode
{
    return [_connectionattributes objectForKey:STNPostgreSQLConnectionParameterSslmode];
}

- (void)setKerberosServiceName:(NSString *)servicename
{
    [_connectionattributes setValue:servicename forKey:STNPostgreSQLConnectionParameterKrbsrvname];
}

- (NSString *)kerberosServiceName
{
    return [_connectionattributes objectForKey:STNPostgreSQLConnectionParameterKrbsrvname];
}

- (void)setService:(NSString *)service
{
    [_connectionattributes setValue:service forKey:STNPostgreSQLConnectionParameterService];
}

- (NSString *)service
{
    return [_connectionattributes objectForKey:STNPostgreSQLConnectionParameterService];
}

- (void)setDelegate:(id)delegate
{
    _delegate = delegate;
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
        
        [connectionstring appendFormat:@"%@='%@' ", key, value];
    }
    
    return connectionstring;
}

- (NSString *)escapeParameterValue:(NSString *)value
{
    // characters to escape: "\", "'"
    unsigned int length = [value lengthOfBytesUsingEncoding:NSASCIIStringEncoding];
    unsigned int c = 0;
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
    if (_pgconn == NULL) {
        userinfo = [NSDictionary dictionaryWithObject:@"Unable to allocate memory for connection" forKey:STNPostgreSQLErrorMessageUserInfoKey];
        *error = [NSError errorWithDomain:STNPostgreSQLErrorDomain code:STNPostgreSQLConnectionError userInfo:userinfo];
        return NO;
    }
    
    status = PQstatus(_pgconn);
    if (status != CONNECTION_OK) {
        userinfo = [NSDictionary dictionaryWithObject:[self recentErrorMessage] forKey:STNPostgreSQLErrorMessageUserInfoKey];
        *error = [NSError errorWithDomain:STNPostgreSQLErrorDomain code:STNPostgreSQLConnectionError userInfo:userinfo];
        return NO;
    } else {
        // collect available data types
        if (! [self reloadAvailableTypes:error]) {
            return NO;
        }
        
        // Set client encoding to UTF-8
        PQexec([self PgConn], [STNPostgreSQLSetUTF8ClientEncodingStatement cStringUsingEncoding:NSASCIIStringEncoding]);
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
    [NSThread detachNewThreadSelector:@selector(connectThreaded:) toTarget:self withObject:self];
}

- (void)connectThreaded:(id)param
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
    [_datatypes release];
    _datatypes = nil;
    if (_pgconn != NULL) {
        PQfinish(_pgconn);
        _pgconn = NULL;
    }
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
    return PQstatus([self PgConn]) == CONNECTION_OK ? YES : NO;
}

- (NSDictionary *)serverInformation
{
    NSMutableDictionary *serverInfo = [[NSMutableDictionary alloc] initWithCapacity:15];
    
    // version number
    NSNumber *versionnumber = [NSNumber numberWithInt:PQserverVersion(_pgconn)];
    [serverInfo setValue:versionnumber forKey:STNPostgreSQLServerInfoVersionNumber];
    
    // protocol version
    NSNumber *protocolversion = [NSNumber numberWithInt:PQprotocolVersion(_pgconn)];
    [serverInfo setValue:protocolversion forKey:STNPostgreSQLServerInfoProtocolVersion];
    
    // backend PID
    NSNumber *backendPID = [NSNumber numberWithInt:PQbackendPID(_pgconn)];
    [serverInfo setValue:backendPID forKey:STNPostgreSQLServerInfoBackendPID];
    
    // formatted version number
    int major = 0, minor = 0, service = 0;
    major = [versionnumber intValue] / 10000;
    minor = ([versionnumber intValue] - major * 10000) / 100;
    service = [versionnumber intValue] - major * 10000 - minor * 100;
    NSString *formattedVersionNumber = [NSString stringWithFormat:@"%d.%d.%d", major, minor, service];
    [serverInfo setValue:formattedVersionNumber forKey:STNPostgreSQLServerInfoFormattedVersionNumber];
    
    NSArray *paramkeys = [NSArray arrayWithObjects:STNPostgreSQLServerInfoServerEncoding,
                          STNPostgreSQLServerInfoClientEncoding,
                          STNPostgreSQLServerInfoIsSuperuser,
                          STNPostgreSQLServerInfoSessionAuthorization,
                          STNPostgreSQLServerInfoDateStyle,
                          STNPostgreSQLServerInfoTimeZone,
                          STNPostgreSQLServerInfoIntegerDatetimes,
                          STNPostgreSQLServerInfoStandardConformingStrings,
                          nil];
    
    NSEnumerator *keyenum = [paramkeys objectEnumerator];
    NSString *key;
    
    while (key = [keyenum nextObject]) {
        NSString *value = [NSString stringWithCString:PQparameterStatus([self PgConn], [key cStringUsingEncoding:NSASCIIStringEncoding])
                                             encoding:NSASCIIStringEncoding];
        [serverInfo setValue:value forKey:key];
    }
    
    return [serverInfo autorelease];
}

- (BOOL)parameteredStatementAvailable
{
    if ([[[self serverInformation] objectForKey:STNPostgreSQLServerInfoProtocolVersion] isEqualToNumber:[NSNumber numberWithInt:PROTOCOLVERSION_PARAM_STATEMENT]]) {
        return YES;
    }
    return NO;
}

- (BOOL)preparedStatementsAvailable
{
    if ([[[self serverInformation] objectForKey:STNPostgreSQLServerInfoProtocolVersion] isEqualToNumber:[NSNumber numberWithInt:PROTOCOLVERSION_PREP_STATEMENT]]) {
        return YES;
    }
    return NO;
}

- (NSString *)recentErrorMessage
{
    return [NSString stringWithCString:PQerrorMessage([self PgConn]) encoding:NSASCIIStringEncoding];
}

- (BOOL)reloadAvailableTypes:(NSError **)error
{
    STNPostgreSQLStatement *datatypestatement = [STNPostgreSQLStatement statementWithConnection:self 
                                                                                   andStatement:STNPostgreSQLLoadDatatypesStatement];
    if (! [datatypestatement execute:error]) {
        return NO;
    } else {
        if (_datatypes != nil) {
            [_datatypes release];
        }
        
        _datatypes = [[[datatypestatement result] dictionaryWithKeyColumn:0
                                                              valueColumn:1
                                                                  keyType:STNPostgreSQLKeyTypeIntNumber] retain];
        *error = nil;
        return YES;
    }
}    

- (STNPostgreSQLTypes *)availableTypes
{
    return [STNPostgreSQLTypes typesWithDictionary:_datatypes];
}    

@end
