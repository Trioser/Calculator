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
		history.text = ""
		display.text = "0.0"
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//
	// My changes
	//
	
	let enterSymbol = "⏎"
	let memoryKey = "M"
	var activeTyping : Bool = false
	var calculatorBrain = CalculatorBrain()

	@IBOutlet weak var display: UILabel!
	
	@IBOutlet weak var history: UILabel!
	
	// Settable/Gettable aka "Computed" property
	private var displayValue : Double? {
		set {
			activeTyping = false
			if newValue == nil {
				display.text = " "
			} else {
				display.text = "\(newValue!)"
			}
		}
		get {
			return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
		}
	}
	
	@IBAction func memorySet(sender: UIButton) {
		if let currentDisplayValue = displayValue {
			activeTyping = false
			calculatorBrain.setMemoryVariable(memoryKey, value: currentDisplayValue)
			displayValue = calculatorBrain.evaluate()
		} else {
			println("Current display value is not valid for memory set key.")
		}
	}
	
	@IBAction func memoryGet(sender: UIButton) {
		if activeTyping {
			enter(enterSymbol)
		}
		display.text = memoryKey
		enter(enterSymbol)
	}
	
	
	@IBAction func operate(sender: UIButton) {
		if activeTyping {
			enter(sender.currentTitle)
		} else {
			history.text! += sender.currentTitle!
		}
		
		if let operatorString = sender.currentTitle {
			if let result = calculatorBrain.performOperation(operatorString) {
				displayValue = result
			}
		}
		
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
	
	@IBAction func appendDecimalPoint(sender: UIButton) {
		if (activeTyping == true) {
			if (display.text!.rangeOfString(".") == nil) {
				display.text = display.text! + "."
			}
		} else {
			display.text = "0."
			activeTyping = true
		}
	}
	
	//
	// An example sort routine showing closure syntax
	//
	@IBAction func arraySort() {
		let names = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]
		println("Unsorted: \(names)")
		let sortedNames = doSort(names, {return $0 > $1}) // equvalent of {(s1: String, s2: String) -> Bool in s2 > s1}
		println("Sorted: \(sortedNames)")
		let reverseSortedName = doSort(names, {return $1 > $0}) // {(s1: String, s2: String) -> Bool in s2 > s1})
		println("Reverse sorted: \(reverseSortedName)")
	}
	
	@IBAction func appendPi(sender: UIButton) {
		if activeTyping {
			enter(enterSymbol)
		}
		display.text = piSymbol
		enter(enterSymbol)
	}
	
	@IBAction func clearEntry(sender: UIButton) {
		displayValue = 0
	}
	
	@IBAction func clear(sender: UIButton) {
		displayValue = 0
		history.text = ""
		calculatorBrain.clear()
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
	
	@IBAction func enter(sender: UIButton) {
		enter(sender.currentTitle)
	}
	
	private func enter(op: String?) {
		history.text! += display.text!

		if let historyOp = op {
			history.text! += historyOp
		}
		
		activeTyping = false
		
		if let operand = displayValue {
			displayValue = calculatorBrain.pushOperand(displayValue)
		} else {
			displayValue = calculatorBrain.pushOperand(display.text!)
		}
	}
}

