//
//  STNPostgreSQLPreparedStatement.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 28.09.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id: STNPostgreSQLPreparedStatement.h 40 2007-05-23 18:59:27Z sst $
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

#import <Cocoa/Cocoa.h>
#import "STNPostgreSQLParameteredStatement.h"

enum STNPostgreSQLPreparedState {
    STNPostgreSQLPreparedStatePrepare = 0,
    STNPostgreSQLPreparedStateExecute = 1
};

@interface STNPostgreSQLPreparedStatement : STNPostgreSQLParameteredStatement {
    NSString *_statementName;
    NSArray  *_parameterTypes;
    int _state;
}

+ (STNPostgreSQLPreparedStatement *)statementWithStatement:(NSString *)statement
                                             andParameters:(NSArray *)parameter;
+ (STNPostgreSQLPreparedStatement *)statementWithConnection:(STNPostgreSQLConnection *)connection 
                                               andStatement:(NSString *)statement 
                                              andParameters:(NSArray *)parameters;

- (BOOL)prepare:(NSError **)error;



@end
