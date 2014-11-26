//
//  Extenstions.swift
//  Emma-zing
//
//  Created by Joshua Pepperman on 11/25/14.
//  Copyright (c) 2014 Joshua Pepperman. All rights reserved.
//

import Foundation

extension Dictionary
{
	static func loadJSONFromBundle(filename: String) -> Dictionary<String, AnyObject>?
	{
		if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json")
		{
			var error: NSError?
			let data: NSData? = NSData(contentsOfFile: path, options: NSDataReadingOptions(), error: &error)
			if let data = data
			{
				let dictionary: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
					options: NSJSONReadingOptions(), error: &error)
				if let dictionary = dictionary as? Dictionary<String, AnyObject>
				{
					return dictionary
				}
				else
				{
					println("Level file '\(filename)' is not valid JSON: \(error!)")
					return nil
				}
			}
			else
			{
				println("Could not load level file: \(filename), error: \(error!)")
				return nil
			}
		}
		else
		{
			println("Could not find level file: \(filename)")
			return nil
		}
	}
}