//
//  STNPostgreSQLConnectionSSLMode.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 19.10.06.
//  Copyright 2006 stiefels.net. All rights reserved.
//
//  $Id$
//

/*!
    @enum STNPostgreSQLConnectionSSLMode
    @abstract   SSL Modes for PostgreSQL connection
    @constant   STNPostgreSQLConnectionSSLModeDisable Disable SSL for connection
    @constant   STNPostgreSQLConnectionSSLModeAllow Allow SSL for connection
    @constant   STNPostgreSQLConnectionSSLModePrefer Prefer SSL for connection
    @constant   STNPostgreSQLConnectionSSLModeRequire Require SSL for connection
 */
enum {
    STNPostgreSQLConnectionSSLModeDisable = 0,
    STNPostgreSQLConnectionSSLModeAllow = 1,
    STNPostgreSQLConnectionSSLModePrefer = 2,
    STNPostgreSQLConnectionSSLModeRequire = 3
};
