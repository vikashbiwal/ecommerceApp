//
//  PollModel.swift
//  ShoppingCartApp
//
//  Created by Aklesh Rathaur on 06/10/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation
import KVAlertView



class PollList {
	var endTime = ""
	var isSubmitted = false
	var id = ""
	var name = ""

	init(_ json:[String:Any]) {

		endTime = Converter.toString(json["endTime"])
		isSubmitted = Converter.toBool(json["isSubmitted"])
		id = Converter.toString(json["pollMasterId"])
		name = Converter.toString(json["pollName"])

	}
}

class PollQuestion {
	var maxLength:Int = 0
	var minLength:Int = 0
	var questionTypeId:Int = 0
	var isRequired = false
	var nextQuestionId:Int = 0
	var questionText = ""
	var answerText = ""
	var id = ""
	var isMAXMIN = false
	var type:Enum_PollQuestionType = .singleoption
	var optionsList = [pollOption]()

	init() {
	}
	
	init(_ json:[String:Any]) {

		id = Converter.toString(json["pollQuestionId"])
		isRequired = Converter.toBool(json["isRequired"])
		questionText = Converter.toString(json["questionText"])
		answerText = Converter.toString(json["answerText"])
		nextQuestionId = Converter.toInt(json["nextQuestionId"])
		maxLength = Converter.toInt(json["maxLength"])
		minLength = Converter.toInt(json["minLength"])
		questionTypeId = Converter.toInt(json["questionType"])
		type = getQuestionType(type: questionTypeId)
		isMAXMIN = (maxLength > 0 && minLength > 0) ? true : false

		if let options = json["pollOption"] as? [[String:Any]] {
			optionsList = options.map({ (obj) -> pollOption in
				return pollOption(text: obj["optionText"] as! String, id: Converter.toString(obj["pollOptionId"]), isSelected:false)
			})
		}
		self.selectOptionOnAnswerText()
	}

	func selectOptionOnAnswerText()  {

		let type = self.type
		switch type {

		case Enum_PollQuestionType.singleoption, .singlepic, .singlepicker:
			self.selectSingleOption()

		case Enum_PollQuestionType.multioptions, .multipic:
			self.selectMultiOption()

		default:
			break

		}
		
	}

	func selectSingleOption()  {

		let array = self.optionsList.map { (obj) -> pollOption in
			var option = obj
			if option.id == self.answerText {
				option.isSelected = true
			}
			return option
		}
		self.optionsList = array
	}

	func selectMultiOption()  {

		let selectedArray = self.answerText.components(separatedBy: ",")
		let array = self.optionsList.map { (obj) -> pollOption in
			var option = obj
			_ = 	selectedArray.filter({ (id) -> Bool in
				if id == option.id {
					option.isSelected = true
				}
				return true
			})
			return option
		}
		self.optionsList = array
	}

	func getQuestionType(type:Int) -> Enum_PollQuestionType {

		switch type {
		case 1:
			return .singleoption
		case 2:
			return .multioptions
		case 3:
			return .singleline
		case 4:
			return .multiline
		case 5:
			return .singlepic
		case 6:
			return .multipic
		case 7:
			return .ratings
		case 8:
			return .number
		case 9:
			return .singlepicker
		case 10:
			return .switchType
		default:
			return .singleoption

		}
	}

	func deselectAllOption()   {
		let array = self.optionsList
		self.optionsList = array.map({ (option) -> pollOption in
			var obj = option
			obj.isSelected = false
			return obj
		})
	}

	func checkIfAnySelectedOptions() -> Bool  {

		let array = self.optionsList.filter { (option) -> Bool in
			return option.isSelected
			}
		return array.count > 0 ? true : false
	}

	func getAllSelectedOptions() -> String  {
		
		let array = self.optionsList.filter { (option) -> Bool in
			return option.isSelected
		}.map { (option) -> String in
			return option.id
		}
		return array.joined(separator: ",")
	}

	func getAllSelectedOptionsArray() -> [String] {

		let array = self.optionsList.filter { (option) -> Bool in
			return option.isSelected
			}.map { (option) -> String in
				return option.id
		}
		return array
	}

	func checkMinAndMaxOptionSelection() -> Bool {

		let array = self.getAllSelectedOptionsArray()
		if array.count > 0 {
			if self.isMAXMIN {
				if array.count >= self.minLength || array.count <= self.maxLength {
					return true
				} else {
					KVAlertView.show(message: "You can select min \(self.minLength) and max \(self.maxLength) option.")
					return false
				}
			} else {
				return true
			}
		}
		else {
			if self.isMAXMIN {
				KVAlertView.show(message: "Select min \(self.minLength) and max \(self.maxLength) option.")
			}
			else {
				KVAlertView.show(message: "Select any option.")
			}
			return false
		}

	}


}

struct pollOption {
	var text = ""
	var id = ""
	var isSelected = false
}

extension PollQuestion {
	//MARK SINGLELINE TEXT VALIDATION
	
	func validateSingleLineText(answer:String) -> Bool  {

		if self.isRequired {
			return self.checkSingleLineText(answer: answer)
		} else {
			if answer.characters.count > 0 {
				return self.checkSingleLineText(answer: answer)
			} else {
				return true
			}
		}
	}

	func checkSingleLineText(answer:String) -> Bool  {

		if self.isMAXMIN {
			if answer.characters.count < self.minLength || answer.characters.count > self.maxLength {
				KVAlertView.show(message: "Min character limit is \(self.minLength) and max character limit is \(self.maxLength)")
				return false
			} else {
				return true
			}
		} else {
			if answer.characters.count > 0 {
				return true
			} else {
				KVAlertView.show(message: "Enter your answer.")
				return false
			}
		}
	}
}



