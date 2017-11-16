//
//  PollQuestionVC.swift
//  ShoppingCartApp
//
//  Created by Aklesh Rathaur on 06/10/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import KVAlertView

enum Enum_PollQuestionType {
	case singleoption, multioptions, singleline, multiline, singlepic, multipic, ratings, number, singlepicker, switchType
}

class PollQuestionVC: ParentViewController {

	@IBOutlet weak var lblQuestion:UILabel!
	@IBOutlet weak var btnSkip:UIButton!
	@IBOutlet weak var btnSubmit:UIButton!
	@IBOutlet weak var viewDropdown:UIView!
	@IBOutlet weak var btnDropdown:UIButton!
	@IBOutlet weak var lblDropdown:UILabel!
	@IBOutlet weak var viewDropdownHeight: NSLayoutConstraint!
	var toolBar:UIToolbar!

	var pollListID = ""
	var questionId = "0"
	var answerId = ""
	var currentQuestion = PollQuestion()
	var isPrevious = false
	var questionCount:Int = 0
	var isAlreadySubmitted = false

    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = UIColor.white
		tableView.tableFooterView = UIView()
		createToolbar()
		getQuestion()
		if isAlreadySubmitted {
			self.tableView.isUserInteractionEnabled = false
		}

    }

	func createToolbar()  {
		toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
		toolBar.barStyle = UIBarStyle.default
		toolBar.isTranslucent = true
		toolBar.items = [
			UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
			UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(toolBarDoneClicked))]
		//toolbar.sizeToFit()
	}

	func toolBarDoneClicked()   {
		self.view.endEditing(true)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	func configureQuestion()  {
		if !isPrevious {
			questionCount += 1
		}

		lblQuestion.text = currentQuestion.questionText
		tableView.reloadData()
		if self.currentQuestion.type == .singlepicker {
			tableView.separatorStyle = .singleLine
		} else {
			tableView.separatorStyle = .none
		}

		if self.currentQuestion.type == .switchType {
			self.answerId = "Yes"
		}

		if self.currentQuestion.type == .singlepicker {
			self.lblDropdown.text = "Select your option"
			self.tableView.isHidden = true
			viewDropdownHeight.constant = 40
			viewDropdown.isHidden = false
		} else {
			self.tableView.isHidden = false
			viewDropdownHeight.constant = 0
			viewDropdown.isHidden = true
		}

	}

	func textFieldDidBeginEditing(_ textField: UITextField) {
		print("textFieldDidBeginEditing")
	}

	override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

	func textFieldDidEndEditing(_ textField: UITextField) {
		answerId = (textField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
	}


}

extension PollQuestionVC {
	//MARK: IBACTION

	@IBAction func btnBackClicked(sender:UIButton)  {

		questionCount -= 1
		if questionCount > 0 {
			isPrevious = true
			self.getQuestion()
		} else {
			self.navigationController?.popViewController(animated: true)
		}
	}


	@IBAction func btnSkipClicked(sender:UIButton)  {
		self.getQuestion()
	}

	@IBAction func btnDropDownClicked(sender:UIButton)  {
		if self.tableView.isHidden {
			self.tableView.isHidden = false
		} else {
			self.tableView.isHidden = true
		}
	}
	
	@IBAction func switchValueChanged(sender: UISwitch) {
		print("switchValueChanged \(sender.isOn)")
		self.answerId = sender.isOn ? "Yes" : "No"
	}

	@IBAction func btnSmileyClicked(sender: UIButton) {
		self.answerId = "\(sender.tag)"
		self.tableView.reloadData()
	}


	@IBAction func btnSubmitClicked(sender:UIButton)  {

		isPrevious = false
		let type = self.currentQuestion.type

		switch type {

		case Enum_PollQuestionType.singleoption :
			self.submitSingleSelection()

		case Enum_PollQuestionType.multioptions :
			self.submitMultiSelection()

		case Enum_PollQuestionType.singleline :
			self.submitSingleLineText()

		case Enum_PollQuestionType.multiline :
			self.submitSingleLineText()

		case Enum_PollQuestionType.singlepic :
			self.submitSingleSelection()

		case Enum_PollQuestionType.multipic :
			self.submitMultiSelection()

		case Enum_PollQuestionType.ratings :
			self.submitRatings()

		case Enum_PollQuestionType.number :
			self.submitNumber()

		case Enum_PollQuestionType.singlepicker :
			self.getQuestion()

		case Enum_PollQuestionType.switchType :
			self.getQuestion()

		}


	}

	func submitSingleSelection()   {

		if self.currentQuestion.isRequired {
			if self.currentQuestion.checkIfAnySelectedOptions() {
				self.answerId = self.currentQuestion.getAllSelectedOptions()
				self.getQuestion()
			} else {
				KVAlertView.show(message: "Select any option.")
			}
		} else {
			self.answerId = self.currentQuestion.getAllSelectedOptions()
			self.getQuestion()
		}

	}

	func submitMultiSelection()   {
		if self.currentQuestion.isRequired {
			if self.currentQuestion.checkMinAndMaxOptionSelection() {
				self.answerId = self.currentQuestion.getAllSelectedOptions()
				self.getQuestion()
			}
		} else {
			if self.currentQuestion.checkIfAnySelectedOptions() {
				if self.currentQuestion.checkMinAndMaxOptionSelection() {
					self.answerId = self.currentQuestion.getAllSelectedOptions()
					self.getQuestion()
				}
			} else {
				self.getQuestion()
			}
		}

	}

	func submitNumber()   {

		if self.currentQuestion.isRequired {
			if self.answerId.characters.count > 0 {
				let number = self.answerId.integerValue
				if number! < self.currentQuestion.minLength || number! > self.currentQuestion.maxLength {
					KVAlertView.show(message: "Min number is \(self.currentQuestion.minLength) and max number is \(self.currentQuestion.maxLength)")
				} else {
					self.getQuestion()
				}

			} else {
				KVAlertView.show(message: "Min number is \(self.currentQuestion.minLength) and max number is \(self.currentQuestion.maxLength)")
			}
		} else {
			if self.answerId.characters.count > 0 {
				let number = self.answerId.integerValue
				if number! < self.currentQuestion.minLength || number! > self.currentQuestion.maxLength {
					KVAlertView.show(message: "Min number is \(self.currentQuestion.minLength) and max number is \(self.currentQuestion.maxLength)")
				} else {
					self.getQuestion()
				}

			} else {
				self.getQuestion()
			}

		}

	}

	func submitSingleLineText()   {
		
		if self.currentQuestion.validateSingleLineText(answer: self.answerId) {
			self.getQuestion()
		}
	}

	func submitRatings()   {

		if self.currentQuestion.isRequired {
			if self.answerId.characters.count > 0 {
				self.getQuestion()
			} else{
				KVAlertView.show(message: "Select any option.")
			}
		} else {
			self.getQuestion()
		}
	}


}

extension PollQuestionVC {

	//MARK: API CALLS


	func getQuestion() {
		let apiParam = ["PollMasterId" : pollListID,"QuestionId" : questionId,"AnswerText" : answerId, "isPrevious":isPrevious] as [String : Any]
		self.showCentralGraySpinner()
		wsCall.getPollQuestion(params: apiParam) { (response) in
			if response.isSuccess {
				if let json = response.json as? [String:Any] {

					self.currentQuestion = PollQuestion(json)
					self.questionId = self.currentQuestion.id
					self.answerId = self.currentQuestion.answerText.characters.count > 0 ? self.currentQuestion.answerText : ""
					self.configureQuestion()
					if	self.currentQuestion.nextQuestionId == -1 {
						self.btnSubmit.setTitle("Submit", for: .normal)
					}
					if	self.currentQuestion.id.integerValue! < 1 {
						KVAlertView.show(message: "Thank you \nYour feedback has been subm itted.")
						self.navigationController?.popViewController(animated: true)
					}
				} else {
					// show thankyou screen
					KVAlertView.show(message: "Thank you \nYour feedback has been submitted.")
					self.navigationController?.popViewController(animated: true)

				}
			}
			self.hideCentralGraySpinner()
		}

	}
}

extension PollQuestionVC: UITableViewDelegate, UITableViewDataSource {

	//MARK: TABLE VIEW DATASOURCE AND DELEGATE

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		let type = self.currentQuestion.type

		switch type {

		case Enum_PollQuestionType.singleoption :
			return self.currentQuestion.optionsList.count

		case Enum_PollQuestionType.multioptions :
			return self.currentQuestion.optionsList.count

		case Enum_PollQuestionType.singleline :
			return 1

		case Enum_PollQuestionType.multiline :
			return 1

		case Enum_PollQuestionType.singlepic :
			return 1

		case Enum_PollQuestionType.multipic :
			return 1

		case Enum_PollQuestionType.ratings :
			return 1

		case Enum_PollQuestionType.number :
			return 1

		case Enum_PollQuestionType.singlepicker :
			return self.currentQuestion.optionsList.count

		case Enum_PollQuestionType.switchType :
			return 1
		}



	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let type = self.currentQuestion.type

		switch type {

		case Enum_PollQuestionType.singleoption :
			let cell = tableView.dequeueReusableCell(withIdentifier: "SingleSelectionCell") as! SingleSelectionCell
			return configureSingleSelectionCell(cell: cell, index: indexPath.row)

		case Enum_PollQuestionType.multioptions :
			let cell = tableView.dequeueReusableCell(withIdentifier: "MultySelectionCell") as! MultySelectionCell
			return configureMultySelectionCell(cell: cell, index: indexPath.row)

		case Enum_PollQuestionType.singleline :
			let cell = tableView.dequeueReusableCell(withIdentifier: "SingleLineTextCell") as! SingleLineTextCell
			return configureSingleLineTextCell(cell: cell, index: indexPath.row)

		case Enum_PollQuestionType.multiline :
			let cell = tableView.dequeueReusableCell(withIdentifier: "MultiLineTextCell") as! MultiLineTextCell
			return configureMultiLineTextCell(cell: cell, index: indexPath.row)

		case Enum_PollQuestionType.singlepic :
			let cell = tableView.dequeueReusableCell(withIdentifier: "ImageOptionCell") as! ImageOptionCell
			cell.selectionStyle = .none
			cell.collectionView.reloadData()
			return cell

		case Enum_PollQuestionType.multipic :
			let cell = tableView.dequeueReusableCell(withIdentifier: "ImageOptionCell") as! ImageOptionCell
			cell.selectionStyle = .none
			cell.collectionView.reloadData()
			return cell

		case Enum_PollQuestionType.ratings :
			let cell = tableView.dequeueReusableCell(withIdentifier: "RatingSmilyCell") as! RatingSmilyCell
			return configureRatingCell(cell: cell, index: indexPath.row)

		case Enum_PollQuestionType.number :
			let cell = tableView.dequeueReusableCell(withIdentifier: "SingleLineTextCell") as! SingleLineTextCell
			return configureSingleLineTextCell(cell: cell, index: indexPath.row)

		case Enum_PollQuestionType.singlepicker :
			let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownSelectionCell") as! DropDownSelectionCell
			return configureDropDownCell(cell: cell, index: indexPath.row)

		case Enum_PollQuestionType.switchType :
			let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchCell
			let text = self.currentQuestion.answerText
			if text.characters.count > 0{
				if text.lowercased() == "Yes".lowercased() {
					cell.switchOnOff.isOn = true
				} else if text.lowercased() == "No".lowercased() {
					cell.switchOnOff.isOn = false
				}
			}
			cell.selectionStyle = .none
			return cell
		}
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		let type = self.currentQuestion.type

		switch type {

		case Enum_PollQuestionType.singlepic,Enum_PollQuestionType.multipic :
			return self.getCollectionViewHeight()

		case Enum_PollQuestionType.multiline :
			return 120

		case Enum_PollQuestionType.ratings :
			return 60

		default:
			return UITableViewAutomaticDimension
			
		}

	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		let type = self.currentQuestion.type

		switch type {

		case Enum_PollQuestionType.singleoption :
			self.didSelectSingleSelectionCell(indexPath: indexPath)

		case Enum_PollQuestionType.multioptions :
			self.didSelectMultiSelectionCell(indexPath: indexPath)

		case Enum_PollQuestionType.singleline :
			print("")


		case Enum_PollQuestionType.multiline :
			print("")


		case Enum_PollQuestionType.singlepic :
			print("")


		case Enum_PollQuestionType.multipic :
			print("")


		case Enum_PollQuestionType.ratings :
			print("")


		case Enum_PollQuestionType.number :
			print("")


		case Enum_PollQuestionType.singlepicker :
				self.tableView.isHidden = true
				self.lblDropdown.text = self.currentQuestion.optionsList[indexPath.row].text
				self.answerId = self.currentQuestion.optionsList[indexPath.row].id


		case Enum_PollQuestionType.switchType :
			print("")

		}

	}


}

extension PollQuestionVC {
	//MARK: DIDSELECT CELLS

	//MARK: SingleSelectionCell
	func didSelectSingleSelectionCell(indexPath:IndexPath)  {

		var option = self.currentQuestion.optionsList[indexPath.row]
		if option.isSelected {
			option.isSelected = false
		} else {
			option.isSelected = true
		}
		self.currentQuestion.deselectAllOption()
		self.currentQuestion.optionsList[indexPath.row] = option
		tableView.reloadData()

	}

	//MARK: SingleSelectionCell
	func didSelectMultiSelectionCell(indexPath:IndexPath)  {

		tableView.reloadData()
		let cell = tableView.cellForRow(at: indexPath) as! MultySelectionCell
		var option = self.currentQuestion.optionsList[indexPath.row]
		if option.isSelected {
			cell.imgView.image = UIImage(named: "ic_uncheck")
			option.isSelected = false
		} else {
			cell.imgView.image = UIImage(named: "ic_Check")
			option.isSelected = true
		}
		self.currentQuestion.optionsList[indexPath.row] = option
	}

	func didSelectDropDownCell(indexPath:IndexPath)  {
		let option = self.currentQuestion.optionsList[indexPath.row]
		self.answerId = option.id
		//self.getQuestion()
	}

}

extension PollQuestionVC {
	//MARK: CONFIGURE CELLS

	//MARK: SingleSelectionCell
	func configureSingleSelectionCell(cell:SingleSelectionCell, index:Int) -> SingleSelectionCell {
		let option = self.currentQuestion.optionsList[index]
		cell.lblTitle.text = option.text
		if option.isSelected {
			cell.imgView.image = UIImage(named: "ic_genderSelect")
		} else {
			cell.imgView.image = UIImage(named: "ic_gendernotSelect")
		}
		cell.selectionStyle = .none
		return cell
	}


	//MARK: MultySelectionCell
	func configureMultySelectionCell(cell:MultySelectionCell, index:Int) -> MultySelectionCell {
		let option = self.currentQuestion.optionsList[index]
		if !option.isSelected {
			cell.imgView.image = UIImage(named: "ic_uncheck")
		} else {
			cell.imgView.image = UIImage(named: "ic_Check")
		}
		cell.lblTitle.text = option.text
		cell.selectionStyle = .none
		return cell
	}

	//MARK: SingleLineTextCell
	func configureSingleLineTextCell(cell:SingleLineTextCell, index:Int) -> SingleLineTextCell {
		cell.txtAnswer.inputAccessoryView = self.toolBar
		cell.txtAnswer.text = self.currentQuestion.answerText
		if self.currentQuestion.type == .number {
			cell.txtAnswer.keyboardType = .numberPad
		}
		cell.selectionStyle = .none
		return cell
	}

	//MARK: MultiLineTextCell
	func configureMultiLineTextCell(cell:MultiLineTextCell, index:Int) -> MultiLineTextCell {
		cell.txtAnswer.inputAccessoryView = self.toolBar
		cell.txtAnswer.text = self.currentQuestion.answerText
		cell.txtAnswer.borderWithRoundCorner(radius: 0.0, borderWidth: 0.5, color: UIColor.lightGray)
		cell.selectionStyle = .none
		return cell
	}

	//MARK:ImageCell
	func configureImageCell(cell:ImageOptionCell, index:Int) -> ImageOptionCell {
		cell.selectionStyle = .none
		let frame = CGRect(x: 0, y: 0, width:cell.collectionView.frame.width, height: self.getCollectionViewHeight())
		cell.collectionView.frame = frame
		cell.layoutSubviews()
		cell.collectionView.reloadData()
		return cell
	}

	//MARK:DropDownCell
	func configureDropDownCell(cell:DropDownSelectionCell, index:Int) -> DropDownSelectionCell {
		let option = self.currentQuestion.optionsList[index]
		if option.isSelected {
			self.lblDropdown.text = option.text
		}
		cell.lblTitle.text = option.text
		cell.selectionStyle = .default
		return cell
	}

	//MARK:RatingCell
	func configureRatingCell(cell:RatingSmilyCell, index:Int) -> RatingSmilyCell {
		//cell.ratingView.delegate = self
		cell.selectionStyle = .none
		if let tag = self.answerId.integerValue {
			for view in cell.stackView.subviews as [UIView] {
				for subview in view.subviews {
					if let btn = subview as? UIButton {
						if btn.tag == tag {
							btn.isSelected = true
						} else {
							btn.isSelected = false
						}
					}
				}


			}
		}
			return cell
	}
}

extension PollQuestionVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,UIGestureRecognizerDelegate {
	//MARK: COLLECTIONVIEW DATASOURCE AND DELEGATE


	// MARK: - collectionview datasource and delegate method

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.currentQuestion.optionsList.count
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

		if IS_IPAD {
			let size = (collectionView.frame.size.width - 20) / 3
			return CGSize(width: size, height:size)

		}else {
			let size = (collectionView.frame.size.width - 10) / 2
			return CGSize(width: size, height:size)

		}

	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 10.0
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 10.0
	}


	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		if self.currentQuestion.type == .singlepic {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"SinglelImageCollCell", for: indexPath) as! SingleImageCollectionViewCell
			let option = self.currentQuestion.optionsList[indexPath.row]
			let urlStr = option.text
			let imgUrl = getImageUrlWithSize(urlString: urlStr, size: cell.frame.size)
			cell.imgView.setImage(url: imgUrl)
			cell.borderWithRoundCorner(radius: 0.0, borderWidth: 1.0, color: UIColor.lightGray)
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
			gestureRecognizer.delegate = self
			cell.imgSelect.addGestureRecognizer(gestureRecognizer)
			gestureRecognizer.view?.tag = indexPath.row

			if option.isSelected {
				cell.imgSelect.image = UIImage(named: "ic_genderSelect")
			} else {
				cell.imgSelect.image = UIImage(named: "ic_gendernotSelect")
			}
			return cell

		} else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"MultiImageCollCell", for: indexPath) as! MultiImageCollectionViewCell
			let option = self.currentQuestion.optionsList[indexPath.row]
			let urlStr = option.text
			let imgUrl = getImageUrlWithSize(urlString: urlStr, size: cell.frame.size)
			cell.imgView.setImage(url: imgUrl)
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
			gestureRecognizer.delegate = self
			cell.imgSelect.addGestureRecognizer(gestureRecognizer)
			gestureRecognizer.view?.tag = indexPath.row
			cell.borderWithRoundCorner(radius: 0.0, borderWidth: 1.0, color: UIColor.lightGray)
			if option.isSelected {
				cell.imgSelect.image = UIImage(named: "ic_Check")
			} else {
				cell.imgSelect.image = UIImage(named: "ic_uncheck")
		 	}
			return cell
		}

	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		let imageModel = PDImageGallery.init(imagePath: self.currentQuestion.optionsList[indexPath.row].text)
		let vc = storyboardProductDetail.instantiateViewController(withIdentifier: "ZoomVC") as! ZoomVC
		vc.imageArray = [imageModel]
		vc.isShowPageControl = false
		//vc.previousVC = .productDetail
		//vc.currentPageIndex = indexPath.row
		self.navigationController?.pushViewController(vc, animated: false)

	}

	func getCollectionViewHeight() -> CGFloat {

		if IS_IPAD {
			let size = floor((self.view.frame.size.width - 50) / 3)
			let count = CGFloat(self.currentQuestion.optionsList.count) / 3
			let height = size * ceil(count)
			return height + 15

		} else {
			let size = floor((self.view.frame.size.width - 40) / 2)
			let count = CGFloat(self.currentQuestion.optionsList.count) / 2
			let height = size * ceil(count)
			return height + 15
		}
	}

	func handleTap(gestureRecognizer: UIGestureRecognizer) {
		let tag = gestureRecognizer.view?.tag
		if self.currentQuestion.type == .singlepic {
		var option = self.currentQuestion.optionsList[tag!]
		if option.isSelected {
		option.isSelected = false
		} else {
		option.isSelected = true
		}
		self.currentQuestion.deselectAllOption()
		self.currentQuestion.optionsList[tag!] = option
		self.tableView.reloadData()

		} else {
		var option = self.currentQuestion.optionsList[tag!]
		if option.isSelected {
		option.isSelected = false
		} else {
		option.isSelected = true
		}
		self.currentQuestion.optionsList[tag!] = option
		self.tableView.reloadData()

		}

	}

}

extension PollQuestionVC:FloatRatingViewDelegate {
	//MARK: RATINGVIEW DELEGATE
	func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
		print("rating is \(rating)")
		self.answerId = "\(rating)"
	}
}
