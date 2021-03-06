//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Richard E Millet on 2/1/15.
//  Copyright (c) 2015 remillet. All rights reserved.
//

import Foundation

let piSymbol = "π"

class CalculatorBrain
{
	private var opStack = [Op]() // Array<Op>
	private var knownOps = [String:Op]() //Dictionary<String, Op>()
	private var variables: [String:Double?] = ["M":nil]

	private enum Op: Printable { // "Printable" is a protocol
		case Operand(Double)
		case UnaryOperation(String, Double -> Double)
		case BinaryOperation(String, (Double, Double) -> Double, precedence: Int)
		case Constant(String, Double)
		case Variable(String, String -> Double?)
		
		var precedence: Int {
			get {
				switch self {
				case .BinaryOperation(_, _, let precedence):
					return precedence
				case .Operand(_):
					return Int.max
				case .UnaryOperation(_, _):
					return Int.max
				case .Constant(_, _):
					return Int.max
				case .Variable(_, _):
					return Int.max
				}
			}
		}
		
		// "Computed" property
		var description: String {
			get {
				switch self {
				case .Operand(let operand):
					return "\(operand)"
				case .UnaryOperation(let unaryOperator, _):
					return unaryOperator
				case .BinaryOperation(let binaryOperator, _, _):
					return binaryOperator
				case .Constant(let symbol, _):
					return symbol
				case .Variable(let symbol, let getValue):
					return symbol
				}
			}
		}
	}
	
	init() {
		func learnOp(op:Op) {
			knownOps[op.description] = op
			println("\(knownOps)")
		}

		learnOp(Op.BinaryOperation("×", *, precedence: 1))
		learnOp(Op.BinaryOperation("÷", {$1 / $0}, precedence: 1))
		learnOp(Op.BinaryOperation("+", +, precedence: 0))
		learnOp(Op.BinaryOperation("-", {$1 - $0}, precedence: 0))
		learnOp(Op.UnaryOperation("√", sqrt))
		learnOp(Op.UnaryOperation("sin", sin))
		learnOp(Op.UnaryOperation("cos", cos))
		learnOp(Op.Constant("π", M_PI))
		learnOp(Op.Variable("M", getMemoryVariable)) // aka {self.variables[$0]!}
		
		println(knownOps.description)
	}
	
	private func describe(ops: [Op]) -> (description: String, precedence: Int, remainingStack: [Op]) {
		if !ops.isEmpty {
			var remainingStack = ops
		
			let op = remainingStack.removeLast()
			switch op {
				
			case .Operand(let operand):
				return (op.description, op.precedence, remainingStack)
				
			case .UnaryOperation(let unaryOperator, _):
				let expression = describe(remainingStack)
				return (unaryOperator + "(" + expression.description + ")", op.precedence, expression.remainingStack)
				
			case .BinaryOperation(let binaryOperator, _, let opPrec):
				var r = describe(remainingStack)
				var l = describe(r.remainingStack)

				if (l.precedence < opPrec) {
					l.description = "(" + l.description + ")"
				}
				
				if (r.precedence < opPrec) {
					r.description = "(" + r.description + ")";
				}
				
				let expression = l.description + binaryOperator + r.description
				return (expression, opPrec, l.remainingStack)
				
			case .Constant(let constant, _):
				return (op.description, op.precedence, remainingStack)
				
			case .Variable(let variableSymbol, _):
				return (op.description, op.precedence, remainingStack)
			}
		}

		return ("?", Int.max, ops)
	}

	var description: String {
		get {
			var descriptionStack = Stack<String>()
			var tempStack = opStack
			
			while !tempStack.isEmpty {
				let tuple = describe(tempStack)
				descriptionStack.push(tuple.description)
				tempStack = tuple.remainingStack
			}
			
			var result = ""
			var expressionOnStack = 0
			while !descriptionStack.isEmpty() {
				let description = descriptionStack.pop()
				result += description + ","
				expressionOnStack++
			}
			
			result = result[result.startIndex..<result.endIndex.predecessor()]
			if expressionOnStack == 1 {
				result += "="
			}
			return result
		}
	}
	
	func clear() {
		opStack = [Op]()
		variables = ["M":nil]
	}
	
	func setMemoryVariable(key: String, value: Double) {
		variables[key] = value
	}
	
	func getMemoryVariable(key: String) -> Double? {
		return variables[key]!
	}
	
	private func evaluate(ops: [Op]) -> (result: Double?, remainingStack: [Op]) {
		if !ops.isEmpty {
			var remainingStack = ops
			let op = remainingStack.removeLast()
			
			switch op {
			case .Operand(let operand):
				return (operand, remainingStack)
			case .UnaryOperation(_, let operation):
				let operandEvaluation = evaluate(remainingStack)
				if let operand = operandEvaluation.result {
					return (operation(operand), operandEvaluation.remainingStack)
				}
			case .BinaryOperation(_, let operation, _):
				let operand1Eval = evaluate(remainingStack)
				if let operand1 = operand1Eval.result {
					let operand2Eval = evaluate(operand1Eval.remainingStack)
					if let operand2 = operand2Eval.result {
						return (operation(operand1, operand2), operand2Eval.remainingStack)
					}
				}
			case .Constant(_, let value):
				return(value, remainingStack)
			case .Variable(let key, let lookup):
				let operand = lookup(key)
				return(operand, remainingStack)
			}
		}
		
		return (nil, ops)
	}
	
	func evaluate() -> Double? {
		//return evaluate(opStack).result
		let (result, remainder) = evaluate(opStack)
		println("\(opStack) = \(result) with \(remainder) left over.")
		return result
	}
	
	func pushOperand(operand: Double?) -> Double? {
		if let operand = operand {
			opStack.append(Op.Operand(operand))
		}
		
		return evaluate()
	}
	
	func pushOperand(symbol: String) -> Double? {
		let op = knownOps[symbol]
		opStack.append(op!)
		return evaluate()
	}
	
	private func popOperand() -> Op {
		var last: Op = opStack.last!
		var result = last
		return result
	}
	
	// push operation onto stack
	func performOperation(symbol: String) -> Double? {
		if let operation = knownOps[symbol] { // 'optional' boolean evaluation?
			opStack.append(operation)
		}
		return evaluate()
	}
}