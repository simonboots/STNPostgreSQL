//
//  STNPostgreSQLResult.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 02.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import <Cocoa/Cocoa.h>


@interface STNPostgreSQLResult : NSObject {
    PGresult *_result;
}

+ (STNPostgreSQLResult *)resultWithPGresult:(PGresult*)result;

- (id)initWithPGresult:(PGresult *)result;

@end
