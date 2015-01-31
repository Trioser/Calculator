//
//  ViewController.swift
//  Calculator
//
//  Created by Richard E Millet on 1/28/15.
//  Copyright (c) 2015 remillet. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//
	// My changes
	//
	
	var activeTyping : Bool = false
	var operandStack = Array<Double>()

	@IBOutlet weak var display: UILabel!
	
	// Settable/Gettable property
	var displayValue : Double {
		set {
			activeTyping = false
			display.text = "\(newValue)"
		}
		get {
			var result : Double = 0
			result = NSNumberFormatter().numberFromString(display.text!)!.doubleValue
			return result
		}
	}
	
	@IBAction func operate(sender: UIButton) {
		if activeTyping {
			enter()
		}
		
		let operand = sender.currentTitle!
		
		switch operand {
		case "×":
			performOperation { $0 * $1 }
		case "÷":
			performOperation({ (leftValue: Double, rightValue: Double) -> Double in
				return leftValue / rightValue
			})
		case "+":
			performOperation { $0 + $1 }
		case "-":
			performOperation(subtract)
		case "√":
			performOperation { sqrt($0) }
		default:
			break
		}
	}
	
	func performOperation(operation: (Double, Double) -> Double) {
		if (operandStack.count >= 2) {
			var rightValue = operandStack.removeLast()
			var leftValue = operandStack.removeLast()
			displayValue = operation(leftValue, rightValue)
			enter()
		}
	}
	
	func performOperation(operation: (Double) -> Double) {
		if (operandStack.count >= 1) {
			var leftValue = operandStack.removeLast()
			displayValue = operation(leftValue)
			enter()
		}
	}
	
	func divide(leftValue: Double, rightValue: Double) -> Double {
		return leftValue / rightValue
	}
	
	func subtract(leftValue: Double, rightValue: Double) -> Double {
		return leftValue - rightValue
	}
	
	func backwards(s1: String, s2: String) -> Bool {
		return s1 > s2
	}
	
	func forwards(s1: String, s2: String) -> Bool {
		return s2 > s1
	}
	
	func doSort(nameList: Array<String>, operation: (String, String) -> Bool) -> Array<String> {
		var arraySize: Int = nameList.count
		var result = nameList
		var finished: Bool = false
		
		while (finished == false) {
			finished = true
			var index: Int = 0
			while (index < arraySize - 1) {
				if (operation(result[index], result[index + 1])) {
					finished = false
					var swap = result[index]
					result[index] = result[index + 1]
					result[index + 1] = swap
				}
				index++
			}
		}
		
		return result
	}
	
	@IBAction func arraySort() {
		let names = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]
		println("Unsorted: \(names)")
		let sortedNames = doSort(names, backwards)
		println("Sorted: \(sortedNames)")
		let reverseSortedName = doSort(names, forwards)
		println("Reverse sorted: \(reverseSortedName)")
	}
	
	@IBAction func appendDigit(sender: UIButton) {
		let digit = sender.currentTitle!
		println("digit = \(digit)")
		
		if (activeTyping == true) {
			display.text = display.text! + digit
		} else {
			display.text = digit
			activeTyping = true
		}
	}
	
	@IBAction func enter() {
		activeTyping = false
		operandStack.append(displayValue)
		println("\(operandStack)")
	}
}

