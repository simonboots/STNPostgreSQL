//
//  STNPostgreSQLParameteredStatement.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 13.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import "STNPostgreSQLParameteredStatement.h"
#import "STNPostgreSQLStatementParameter.h"
#import "STNPostgreSQLTypes.h"

struct STNPostgreSQLRawParameterArray {
    unsigned int *types;
    char **values;
    int *lengths;
    int *formats;
};

@implementation STNPostgreSQLParameteredStatement

#pragma mark initializers/dealloc

+ (STNPostgreSQLParameteredStatement *)statement
{
    return [[[self alloc] init] autorelease];
}

+ (STNPostgreSQLParameteredStatement *)statementWithConnection:(STNPostgreSQLConnection *)connection
{
    return [[[self alloc] initWithConnection:connection] autorelease];
}

+ (STNPostgreSQLParameteredStatement *)statementWithStatement:(NSString *)statement
{
    STNPostgreSQLParameteredStatement *_statement = [self statement];
    [_statement setStatement:statement];
    return _statement;
}

+ (STNPostgreSQLParameteredStatement *)statementWithConnection:(STNPostgreSQLConnection *)connection 
                                                  andStatement:(NSString *)statement
{
    STNPostgreSQLParameteredStatement *_statement = [self statement];
    [_statement setStatement:statement];
    return _statement;
}


+ (STNPostgreSQLParameteredStatement *)statementWithStatement:(NSString *)statement
                                                andParameters:(NSArray *)parameters
{
    STNPostgreSQLParameteredStatement *_statement = [self statementWithStatement:statement];
    [_statement setParameters:parameters];
    return _statement;
}
    
+ (STNPostgreSQLParameteredStatement *)statementWithConnection:(STNPostgreSQLConnection *)connection
                                                  andStatement:(NSString *)statement 
                                                 andParameters:(NSArray *)parameters
{
    STNPostgreSQLParameteredStatement *_statement = [self statementWithConnection:connection
                                                                     andStatement:statement];
    [_statement setParameters:parameters];
    return _statement;
}

- (id)initWithConnection:(STNPostgreSQLConnection *)connection
{
    self = [super initWithConnection:connection];
    if (self != nil) {
        _parameters = [[NSMutableArray alloc] init];
    }
    return self;    
}

- (id)init {
    return [self initWithConnection:nil];
}

- (void) dealloc {
    [_parameters release];
    [super dealloc];
}

#pragma mark parameter handling

- (int)addParameter:(STNPostgreSQLStatementParameter *)parameter
{
    int index;
    @synchronized(_parameters) {
        [_parameters addObject:parameter];
        index = ([_parameters count]-1);
    }
    return index;
}

- (int)addParameterWithValue:(id)value type:(NSString *)type
{
    STNPostgreSQLStatementParameter *parameter = 
        [STNPostgreSQLStatementParameter parameterWithValue:value
                                                   datatype:[[[self connection] availableTypes] oidForType:type]];
    return [self addParameter:parameter];
}

- (int)parameterCount
{
    return [_parameters count];
}

- (void)clearParameters
{
    [_parameters removeAllObjects];
}

- (NSArray *)parameters
{
    return (NSArray *)_parameters;
}

- (void)setParameters:(NSArray *)parameters
{
    [_parameters release];
    _parameters = [parameters mutableCopy];
}

- (STNPostgreSQLStatementParameter *)parameterAtIndex:(unsigned int)index
{
    return [[self parameters] objectAtIndex:index];
}

- (void)insertParameter:(STNPostgreSQLStatementParameter *)parameter atIndex:(unsigned int)index
{
    [_parameters insertObject:parameter atIndex:index];
}

- (void)dropParameterAtIndex:(unsigned int)index
{
    [_parameters removeObjectAtIndex:index];
}

- (struct STNPostgreSQLRawParameterArray)buildRawParameterArray
{
    NSEnumerator *enumerator = [[self parameters] objectEnumerator];
    id aParameter;
    int count = 0;
    int paramCount = [[self parameters] count];
    struct STNPostgreSQLRawParameterArray rawParameterData;
    
    // starting ugly C operations
    
    rawParameterData.types = (unsigned int *)malloc(paramCount * sizeof(unsigned int));
    rawParameterData.values = (char**)malloc(paramCount * sizeof(char*));
    rawParameterData.lengths = (int *)malloc(paramCount * sizeof(int));
    rawParameterData.formats = (int *)malloc(paramCount * sizeof(int));
    
    while (aParameter = [enumerator nextObject]) {
        if ([aParameter format] == STNPostgreSQLParameterFormatString) {
            // STNPostgreSQLParameterFormatString
            const char *value = [[[aParameter value] description] cStringUsingEncoding:NSASCIIStringEncoding];
            rawParameterData.values[count] = (char *)malloc((strlen(value)+1) * sizeof(char));
            strcpy(rawParameterData.values[count], value);
        } else {
            // STNPostgreSQLParameterFormatBinary
            const void *value = [[aParameter value] bytes];
            rawParameterData.values[count] = (void *)malloc([aParameter length] * sizeof(char));
            memcpy(rawParameterData.values[count], value, (size_t)[aParameter length]);
        }

        rawParameterData.types[count] = [aParameter datatype];
        rawParameterData.lengths[count] = [aParameter length];
        rawParameterData.formats[count] = (int)[aParameter format];
        count++;
    }
    
    return rawParameterData;
}

#pragma mark statement execution

- (PGresult *)PQexecute
{
    struct STNPostgreSQLRawParameterArray rawArray = [self buildRawParameterArray];
    PGresult *result = PQexecParams([[self connection] PgConn], 
                                    [[self statement] cStringUsingEncoding:NSASCIIStringEncoding],
                                    [[self parameters] count],
                                    rawArray.types,
                                    (const char* const *)rawArray.values,
                                    rawArray.lengths,
                                    rawArray.formats,
                                    0);
    
    free(rawArray.values);
    free(rawArray.types);
    free(rawArray.lengths);
    free(rawArray.formats);
    return result;
}

@end
