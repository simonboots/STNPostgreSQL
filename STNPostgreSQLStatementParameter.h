//
//  STNPostgreSQLStatementParameter.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 13.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import <Cocoa/Cocoa.h>

enum STNPostgreSQLParameterFormat {
    STNPostgreSQLParameterFormatString = 0,
    STNPostgreSQLParameterFormatBinary = 1
};

@interface STNPostgreSQLStatementParameter : NSObject {
    NSString *_datatype;
    int _length;
    int _format;
    id  _value;
}

+ (STNPostgreSQLStatementParameter *)parameterWithValue:(id)value datatype:(NSString *)datatype;
+ (STNPostgreSQLStatementParameter *)parameterWithBinaryValue:(NSData *)value datatype:(NSString *)datatype;

- (id)initWithValue:(id)value datatype:(NSString *)datatype;
- (id)initWithBinaryValue:(NSData *)value datatype:(NSString *)datatype;

- (void)setDatatype:(NSString *)datatype;
- (NSString *)datatype;
- (int)length;
- (int)format;
- (void)setValue:(id)value;
- (void)setBinaryValue:(NSData *)value;
- (id)value;
- (void)dealloc;

@end
