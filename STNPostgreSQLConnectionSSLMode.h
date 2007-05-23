//
//  STNPostgreSQLConnectionSSLMode.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 19.10.06.
//  Copyright 2006 stiefels.net. All rights reserved.
//
//  $Id$
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

/*!
    @enum STNPostgreSQLConnectionSSLMode
    @abstract   SSL Modes for PostgreSQL connection
    @constant   STNPostgreSQLConnectionSSLModeDisable Disable SSL for connection
    @constant   STNPostgreSQLConnectionSSLModeAllow Allow SSL for connection
    @constant   STNPostgreSQLConnectionSSLModePrefer Prefer SSL for connection
    @constant   STNPostgreSQLConnectionSSLModeRequire Require SSL for connection
 */
typedef enum {
    STNPostgreSQLConnectionSSLModeDisable = 0,
    STNPostgreSQLConnectionSSLModeAllow = 1,
    STNPostgreSQLConnectionSSLModePrefer = 2,
    STNPostgreSQLConnectionSSLModeRequire = 3
} STNPostgreSQLConnectionSSLMode;
