//
//  STNPostgreSQLConnection.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 16.10.06.
//  Copyright 2006 stiefels.net. All rights reserved.
//
//  $Id$
//

#import <Cocoa/Cocoa.h>

/*!
    @class       STNPostgreSQLConnection 
    @superclass  NSObject
    @abstract    Manages connection to PostgreSQL server
    @discussion  (comprehensive description)
*/
@interface STNPostgreSQLConnection : NSObject {

    /*! @var *_pgconn PGconn object (libpg native) */
    PGconn          *_pgconn;
    
    /*! @var *_connectionattributes connection string attributes */
    NSDictionary    *_connectionattributes; // keys and default values by PGconndefaults
    
    /*! @var delegate delegate object to receive connection information */
    id              delegate;
    
    /*NSString    *_host;
    NSString    *_hostaddress;  // see PostgreSQL docs chapter 28.1
    NSString    *_port;
    NSString    *_dbname;
    NSString    *_user;
    NSString    *_password;
    NSString    *_connecttimeout;
    NSString    *_options;
    NSString    *_sslmode;
    NSString    *_krbsrvname;   // Kerberos service name */

    
}

/*! @functiongroup connection attributes setters/getters */

/*!
    @method     setHost:
    @abstract   Sets name of host to connect to
    @discussion If this begins with a slash, it specifies Unix-domain communication rather than TCP/IP communication; the value is the name of the directory in which the socket file is stored.
    @param      host Name of host or location of Unix-domain
*/
- (void)setHost:(NSString *)host;

/*!
    @method     host
    @abstract   returns name of host to connect to
    @result     name of the host/Unix-domain
*/
- (NSString *)host;

/*!
    @method     setHostAddress:
    @abstract   Sets numeric IP address of host to connect to
    @discussion Numeric IP address of host to connect to. This should be in the standard IPv4 address for- 
 mat, e.g., 172.28.40.9. If your machine supports IPv6, you can also use those addresses. 
 TCP/IP communication is always used when a nonempty string is specified for this param- 
 eter. 
 Using setHostAddress: instead of setHost: allows the application to avoid hostname lookups.
 However, Kerberos authentication requires the host name. The following therefore applies: If host is
 specified without hostaddress, a host name lookup occurs. If hostaddress is specified without host, the value 
 for hostaddress gives the remote address. When Kerberos is used, a reverse name query 
 occurs to obtain the host name for Kerberos. If both host and hostaddress are specified, 
 the value for hostaddress gives the remote address; the value for host is ignored, unless 
 Kerberos is used, in which case that value is used for Kerberos authentication.
    @param      address IP address of host
*/
- (void)setHostAddress:(NSString *)hostaddress;


/*!
    @method     hostAddress
    @abstract   returns IP address of host (if set)
    @result     IP address of host (if set)
*/
- (NSString *)hostAddress;

/*!
    @method     setPort:
    @abstract   Sets port number of host
    @discussion Port number to connect to at the server host, or socket file name extension for Unix-domain 
 connections.
 Defaults to 5432, which is the standard port for PostgreSQL
    @param      port port number (standard port: 5432)
*/
- (void)setPort:(NSString *)port;

/*!
    @method     port
    @abstract   Returns port number of host
    @result     port number
*/
- (NSString *)port;

/*!
    @method     setDatabaseName:
    @abstract   Sets database name
    @discussion Defaults to the user name
    @param      databasename database name
*/
- (void)setDatabaseName:(NSString *)databasename;

/*!
    @method     databaseName
    @abstract   Return database name
    @result     database name
*/
- (NSString *)databaseName;

/*!
    @method     setUserName:
    @abstract   Sets PostgreSQL user name to connect as
    @discussion Defaults to the same as the operating system name of the user running the application
    @param      username user name
*/
- (void)setUserName:(NSString *)username;

/*!
    @method     userName
    @abstract   Returns PostgreSQL user name
    @result     user name
*/
- (NSString *)userName;

/*!
    @method     setPassword:
    @abstract   Sets password
    @discussion Password to be used if server requires password authentication
    @param      password password
*/
- (void)setPassword:(NSString *)password;


/*!
    @method     password
    @abstract   Returns password
    @result     password
*/
- (NSString *)password;

/*!
    @method     setConnectionTimeout:
    @abstract   Sets maximum wait for connection
    @discussion Zero or not set means wait indefinitely; It is not recommended to use a timeout of less than 2 seconds
    @param      seconds timeout in seconds
*/
- (void)setConnectionTimeout:(NSNumber *)seconds;


/*!
    @method     connectionTimeout
    @abstract   Returns maximum wait for timeout
    @result     timeout in seconds
*/
- (NSNumber *)connectionTimeout;

/*!
    @method     setCommandLineOptions:
    @abstract   command line options to be sent to the server
    @param      options command line options
*/
- (void)setCommandLineOptions:(NSString *)options;

/*!
    @method     commandLineOptions
    @abstract   Returns command line options
    @result     command line options
*/
- (NSString *)commandLineOptions;

/*!
    @method     setSSLMode:
    @abstract   Sets SSL connection priority
    @discussion This option determines whether or with what priority an SSL connection will be negotiated with the server.
 Modes see STNPostgreSQLConnectionSSLMode.h
    @param      sslmode SSL connection priority
*/
- (void)setSSLMode:(STNPostgreSQLConnectionSSLMode)sslmode;

/*!
    @method     SSLMode
    @abstract   Returns SSL connection priority
    @discussion Modes see STNPostgreSQLConnectionSSLMode.h
    @result     SSL connection priority
*/
- (STNPostgreSQLConnectionSSLMode)SSLMode;

/*!
    @method     setKerberosServiceName:
    @abstract   Sets Kerberos 5 service name
    @discussion Kerberos service name to use when authenticating with Kerberos 5.
    @param      servicename service name
*/
- (void)setKerberosServiceName:(NSString *)servicename;

/*!
    @method     kerberosServiceName
    @abstract   Returns Kerberos 5 service name
    @result     service name
*/
- (NSString *)kerberosServiceName;

/*!
    @method     setService:
    @abstract   Sets service name to use for additional parameters.
    @discussion It specifies a service name in 
 pg_service.conf that holds additional connection parameters. This allows applications 
 to specify only a service name so connection parameters can be centrally maintained. See 
 share/pg_service.conf.sample in the installation directory for information on how 
 to set up the file. 
    @param      service service name
*/
- (void)setService:(NSString *)service;

/*!
    @method     service
    @abstract   Resturn service name
    @result     service name
*/
- (NSString *)service;

/*!
    @method     setDelegate:
    @abstract   Sets delegate to receive connection information
    @discussion Delegate will receive connection information through method calls.
 The calls are described in the STNPostgreSQLConnectionDelegateMethods informal protocol
    @param      delegate delegate object
*/
- (void)setDelegate:(id)delegate;

/*!
    @method     delegate
    @abstract   Returns delegate object
    @result     delegate object
*/
- (id)delegate;

/*!
    @method     connect:
    @abstract   Start connection to PostgreSQL server
    @discussion As the connection can take some time, calling this method directly will cause your application to hang until connection is made (or not).
 Use startConnection to use separate thread for connection procedure.
    @param      error pointer to error object. Will contain useful information if the connection failes.
    @result     YES if connection was successfully established, NO if connection could not be established
*/
- (BOOL)connect:(NSError **)error;

/*!
    @method     startConnection
    @abstract   starts connection in separate thread
    @discussion Uses STNPostgreSQLConnectionDelegateMethods to talk to main thread
*/
- (void)startConnection;

/*!
    @method     disconnect
    @abstract   ends connection to PostgreSQL server
*/
- (void)disconnect;

/*!
    @method     reconnect:
    @abstract   closes and re-establishes server connection
    @discussion As the re-connection can take some time, calling this method directly will cause your application to hang until connection is made (or not).
 Use startReconnection to use separate thread for reconnection procedure.
    @param      error pointer to error object. Will contain useful information if the connection failes.
    @result     YES if connection was successfully established, NO if connection could not be established
*/
- (BOOL)reconnect:(NSError *)error;


/*!
    @method     isConnected
    @abstract   returns connection status
    @result     YES if connection is available, NO if connection is not available
*/
- (BOOL)isConnected;


/*!
    @method     serverInformation
    @abstract   Returns useful information about the server and the connection
    @discussion method provides inforamtion in NSDictionary collection. The values are:
    Key: @"versionnumber" => NSString: Version number of server (e.g.: 8.1.4)
	Key: @"protocolversion" => NSNumber: Version number of protocol (e.g. 3)
	Key: @"backendPID" => NSNumber: Backend process ID of connection
    @result     dictionary with information
*/
- (NSDictionary *)serverInformation;

/*!
    @method     parameteredStatementAvailable
    @abstract   Returns if parametered statements are available through connection
    @discussion Since parametered statements are only available in protocol version 3 or above you should check if the connection supports this feature.
    @result     YES if parametered statements are available, NO if not
*/
- (BOOL)parameteredStatementAvailable;

/*!
    @method     preparedStatementsAvailable
    @abstract   Returns if prepared statements are available through connection
    @discussion Since parametered statements are only available in protocol version 3 or above you should check if the connection supports this feature.
    @result     YES if parametered statements are available, NO if not
*/
- (BOOL)preparedStatementsAvailable;


/*!
    @method     recentErrorMessage
    @abstract   Returns the error message most recently generated by an operation on the connection.
    @result     most recent error message
*/
- (NSString *)recentErrorMessage;

@end
@interface NSObject (STNPostgreSQLConnectionDelegateMethods)
// connection methods
- (BOOL)connectionAttemptShouldStart;
- (void)connectionAttemptWillStart;
- (void)connectionAttemptEnded:(BOOL)success error:(NSError *)error;
// disconnection methods
- (BOOL)disconnectionAttemptShouldStart;
- (void)disconnectionAttemptWillStart;
- (void)disconnectionAttemptEnded;
@end
