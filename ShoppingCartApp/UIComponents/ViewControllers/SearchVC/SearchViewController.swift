
//
//  SearchViewController.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 23/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class SearchViewController: ParentViewController {
    @IBOutlet var searchView: SearchView!
    let searchViewModel = SearchViewModel()
    
    var debouncer: Debouncer!
    weak var speechController: SpeechViewController?
    var searchResultAction: (String, SearchNavigateType,NSAttributedString?)-> Void = {_ in}
    
    fileprivate enum SearchOption: Int {
        case Text = 0, Voice, BarCode, ImageCapture
    }
    
    fileprivate enum SearchVCSegue: String {
        case voice = "VoiceSearchSegue"
        case barCode = "BarCodeSearchSegue"
    }
    
    enum SearchNavigateType {
        case productDetail, productList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        searchView.searchTextField.becomeFirstResponder()
        searchView.viewController = self
        searchView.searchTextField.delegate = self
        searchView.actionBlock = self.searchViewActionBlock
        self.setDebouncer()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.searchView.searchOptionShowing = true
        }
        
        
        _defaultCenter.addObserver(self, selector: #selector(self.back_btnClicked(sender:)), name: NSNotification.Name(rawValue: "TabbarDidChangeTab"), object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeKeyboardObserver()
        //_defaultCenter.removeObserver(self)
    }
    
    
    //Search view action block. ex - user select any result item and navigate to related screen.
    lazy var searchViewActionBlock: ((SearchItem,NSAttributedString))-> Void = { [weak self] (searchItem , string) in
        if searchItem.apiParameters.contains("CategoryId") {
          self?.searchResultAction(searchItem.apiParameters, .productList, string)
          //self?.searchResultAction(searchItem.apiParameters, .productList)
            
        } else if searchItem.apiParameters.contains("ProductId") {
            
            if let json = searchItem.apiParameters.json as? [String : Any] {
                let productId = Converter.toString(json["ProductId"])
                self?.searchResultAction(productId, .productDetail,string)
            }
        }
    }
    
    //setting debouncer for avoiding unnessesary calls of search API
    func setDebouncer() {
        debouncer = Debouncer(delay: 1.5, callback: { [weak self] in
            if let selff = self {
                selff.searchWith(text: selff.searchView.searchTextField.text!)
                selff.speechController?.dismiss(animated: false, completion: nil)
            }
        })
    }
    
    //MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SearchVCSegue.voice.rawValue {
            if let speechVC = segue.destination as? SpeechViewController {
                speechVC.speechCompletion = { [unowned self] speechText in
                    self.searchView.searchTextField.text = speechText
                    self.searchView.searchTextField.delegate?.searchBar?(self.searchView.searchTextField,
                                                                         textDidChange: speechText)
                }
                self.speechController = speechVC
            }
            
        } else if segue.identifier == SearchVCSegue.barCode.rawValue {
            
        }
    }
    
}



//MARK: IBActions
extension SearchViewController {
    @IBAction func back_btnClicked(sender: UIButton?) {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
        }) {success in
            _ = self.dismiss(animated: false, completion: nil)
        }
        _defaultCenter.removeObserver(self)
    }
    
    @IBAction func showHideSearchOptions_btnClicked(sender: UIButton) {
        searchView.searchOptionShowing = !searchView.searchOptionShowing
    }
    
    @IBAction func searchOptions_btnClicked(sender: UIButton) {
        if sender.tag == SearchOption.Voice.rawValue {
            performSegue(withIdentifier: SearchVCSegue.voice.rawValue, sender: nil)
            
        } else if sender.tag == SearchOption.BarCode.rawValue {
            performSegue(withIdentifier: SearchVCSegue.barCode.rawValue, sender: nil)
            
        } else if sender.tag == SearchOption.ImageCapture.rawValue {
            //TODO:
        }
        self.searchView.searchOptionShowing = false
    }
    
}

//MARK:- UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)     {
        if !searchText.isEmpty {
            debouncer.call()
        } else {
            self.searchView.searchResults = []
        }
        
        if searchView.searchOptionShowing {
            searchView.searchOptionShowing = false
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


//MARK:- UIKeyboardObserver
extension SearchViewController: UIKeyboardObserver {
    
    func keyboardWillShow(nf: NSNotification) {
        if let kFrame = nf.userInfo?[UIKeyboardFrameEndUserInfoKey] {
            if let kf = kFrame as? CGRect {
                var inset = searchView.tableView.contentInset
                inset.bottom = kf.height
                searchView.tableView.contentInset = inset
            }
        }
    }
    
    func keyboardWillHide(nf: NSNotification) {
        var inset = searchView.tableView.contentInset
        inset.bottom = 50
        searchView.tableView.contentInset = inset
    }
}

//MARK:- Other
extension SearchViewController {
    func searchWith(text: String) {
        searchViewModel.searchItemsWith(text: text, completion: {[unowned self] resluts in
            self.searchView.searchResults = resluts
            
        })
        
    }
}

