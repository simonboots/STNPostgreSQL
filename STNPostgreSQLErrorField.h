//
//  STNPostgreSQLErrorField.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 15.04.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import <Cocoa/Cocoa.h>

@interface STNPostgreSQLErrorField : NSObject {
    NSDictionary *_errorField;
}

+ (STNPostgreSQLErrorField *)errorFieldWithPGResult:(PGresult *)result;

- (id)initWithPGResult:(PGresult *)result;
- (NSString *)valueForField:(unsigned int)field;

@end
