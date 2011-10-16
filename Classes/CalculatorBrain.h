//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Matthew Fichman on 9/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CalculatorBrain : NSObject {
	double operand;
	NSString *waitingOperation;
	double waitingOperand;
	double savedOperand;
	NSString *error;
	NSMutableArray *expression;
}

@property (readonly) NSString *error;
@property (copy) id expression;
@property double operand;

- (void)setVariableAsOperand:(NSString *)variableName;
- (double)performOperation:(NSString *)operation;


+ (double)evaluateExpression:(id)anExpression
		 usingVariableValues:(NSDictionary *)variables;

+ (NSSet *)variablesInExpression:(id)anExpression;
+ (NSString *)descriptionOfExpression:(id)anExpression;

+ (id)propertyListForExpression:(id)anExpression;
+ (id)expressionForPropertyList:(id)propertyList;


@end
