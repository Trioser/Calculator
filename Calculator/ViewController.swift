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

	@IBOutlet weak var display: UILabel!

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
}

