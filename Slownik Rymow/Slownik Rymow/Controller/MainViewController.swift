//
//  MainViewController.swift
//  Slownik Rymow
//
//  Created by bucci on 23.03.2015.
//  Copyright (c) 2016 Michał Buczek. All rights reserved.
//

import UIKit
import SystemConfiguration

enum RhymePrecisionSelectedButtonEnum: Int {
    case PreciseRhymes = 0
    case NonPreciseRhymes = 1
}

enum SortMethodSelectedButtonEnum: Int {
    case Alphabetical = 0
    case Random = 1
}

class MainViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var rhymeCountStepper: UIStepper!
    @IBOutlet var rhymeCountLabel: UILabel!
    @IBOutlet var rhymePrecisionSegmentedControl: UISegmentedControl!
    @IBOutlet var rhymeSortOrderSegmentedControl: UISegmentedControl!
    @IBOutlet var inputWord: BorderTextField!
    @IBOutlet var searchRhymeButton: BorderButtonView!
    
    var foundRhymes = [FoundRhyme]()
    let textCellIdentifier = "TextCell"
    
    //MARK: - Dependency injection
    
    var rhymeDefinitionManager = RhymeDefinitionManager()
    var rhymeFinderManager = RhymeFinderManager()
    var alertFactory: AlertViewFactory?
    
    //MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        inputWord.delegate = self
        
        alertFactory = AlertViewFactory(vc: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        inputWord.becomeFirstResponder()
    }
    
    //MARK: - Storyboard actions
    
    @IBAction func rhymeCountStepperValueChanged(sender: UIStepper) {
        rhymeCountLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func searchForRhymes(sender: AnyObject) {
        self.inputWord.resignFirstResponder()
        guard inputWord.text?.isEmpty == false else {
            return
        }
        
        clearRhymesTable()
        alertFactory?.showLoadingAlert(arePreciseRhymesBeingSearched())
        
        rhymeFinderManager.getRhymesWithParameters(SearchParameters(word: self.inputWord.text!.lowercaseString, sortMethod: setSortOrderParam(), rhymePrecision: setRhymePrecisionParam(), rhymeLenght: Int(self.rhymeCountStepper.value))) {
            status in
            
            switch status {
            case .Failure(let error):
                print("error")
                self.dismissViewControllerAnimated(true) {
                    self.alertFactory?.showErrorAlert(error, word: self.inputWord.text!.lowercaseString)
                }
            case .Success(let foundRhymesList):
                self.foundRhymes = foundRhymesList
                self.tableView.reloadData()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
        }
    }
    
    func clearRhymesTable() {
        foundRhymes = [String]()
        tableView.reloadData()
    }
    
    //MARK: - Search parameters
    
    func arePreciseRhymesBeingSearched() -> Bool {
        return rhymePrecisionSegmentedControl.selectedSegmentIndex == RhymePrecisionSelectedButtonEnum.PreciseRhymes.rawValue
    }
    
    func setRhymePrecisionParam() -> String {
        print(RhymePrecisionSelectedButtonEnum.init(rawValue: 0)) // to daje dobry enum
        
        return rhymePrecisionSegmentedControl.selectedSegmentIndex == RhymePrecisionSelectedButtonEnum.PreciseRhymes.rawValue ? "D" : "N"
        
    }
    
    func setSortOrderParam() -> String {
        return rhymeSortOrderSegmentedControl.selectedSegmentIndex == SortMethodSelectedButtonEnum.Alphabetical.rawValue ? "A" : "R"
        
    }
}







