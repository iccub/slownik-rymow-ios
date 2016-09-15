//
//  MainViewController.swift
//  Slownik Rymow
//
//  Created by bucci on 23.03.2015.
//  Copyright (c) 2016 Michał Buczek. All rights reserved.
//

import UIKit
import SystemConfiguration

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        inputWord.becomeFirstResponder()
    }
    
    //MARK: - Storyboard actions
    
    @IBAction func rhymeCountStepperValueChanged(_ sender: UIStepper) {
        rhymeCountLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func searchForRhymes(_ sender: AnyObject) {
        self.inputWord.resignFirstResponder()
        guard inputWord.text?.isEmpty == false else {
            return
        }
        
        clearRhymesTable()
        alertFactory?.showLoadingAlert(arePreciseRhymesBeingSearched())
        
        rhymeFinderManager.getRhymesWithParameters(SearchParameters(word: self.inputWord.text!.lowercased(), sortMethod: selectedSortOrder(), rhymePrecision: selectedRhymePrecision(), rhymeLenght: Int(self.rhymeCountStepper.value))) {
            status in
            
            switch status {
            case .failure(let error):
                self.dismiss(animated: true) {
                    self.alertFactory?.showErrorAlert(error, word: self.inputWord.text!.lowercased())
                }
            case .success(let foundRhymesList):
                self.foundRhymes = foundRhymesList
                self.tableView.reloadData()
                self.dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
    func clearRhymesTable() {
        foundRhymes = [String]()
        tableView.reloadData()
    }
    
    //MARK: - Search parameters
    
    func arePreciseRhymesBeingSearched() -> Bool {
        return rhymePrecisionSegmentedControl.selectedSegmentIndex == RhymePrecision.PreciseRhymes.segmentedControlIndex
    }
    
    func selectedRhymePrecision() -> String {
        return rhymePrecisionSegmentedControl.selectedSegmentIndex == RhymePrecision.PreciseRhymes.segmentedControlIndex ? RhymePrecision.PreciseRhymes.parameterValue : RhymePrecision.NonPreciseRhymes.parameterValue
    }
    
    func selectedSortOrder() -> String {
        return rhymeSortOrderSegmentedControl.selectedSegmentIndex == SortOrder.Alphabetical.segmentedControlIndex ? SortOrder.Alphabetical.parameterValue : SortOrder.Random.parameterValue
    }
}
