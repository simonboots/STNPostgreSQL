//
//  STNPostgreSQLType.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 08.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import <Cocoa/Cocoa.h>

@interface STNPostgreSQLTypes : NSObject {
    NSDictionary *_types;
}

+ (STNPostgreSQLTypes *)typesWithDictionary:(NSDictionary *)dictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (void)setTypes:(NSDictionary *)types;
- (NSDictionary *)types;
- (NSString *)typeWithOid:(unsigned int)oid;
- (unsigned int)oidForType:(NSString *)type;

@end
