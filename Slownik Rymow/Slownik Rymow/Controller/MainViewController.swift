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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
    
    @IBAction func inputWordEditingDidEnd(_ sender: UITextField) {
        findRhymes()
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        //Check to not trigger findRhyme() method twice
        if !inputWord.isFirstResponder {
            findRhymes()
        } else {
            self.inputWord.resignFirstResponder()
        }
    }
    
    func findRhymes() {
        self.inputWord.resignFirstResponder()
        guard inputWord.text?.isEmpty == false else {
            return
        }
        
        clearRhymesTable()
        activityIndicator.startAnimating()
        
        DispatchQueue.global().async {
            let searchParameters = SearchParameters(word: self.inputWord.text!.lowercased(),
                                                    sortMethod: self.selectedSortOrder(),
                                                    rhymePrecision: self.selectedRhymePrecision(),
                                                    rhymeLenght: Int(self.rhymeCountStepper.value))
            
            self.rhymeFinderManager.findRhymes(with: searchParameters) { status in
                
                switch status {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.alertFactory?.showErrorAlert(error, word: self.inputWord.text!.lowercased())
                    }
                    
                case .success(let foundRhymes):
                    DispatchQueue.main.async {
                        self.foundRhymes = foundRhymes
                        self.tableView.reloadData()
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    func clearRhymesTable() {
        foundRhymes = []
        tableView.reloadData()
    }
    
    //MARK: - Search parameters
    
    func arePreciseRhymesBeingSearched() -> Bool {
        return rhymePrecisionSegmentedControl.selectedSegmentIndex == 0
    }
    
    func selectedRhymePrecision() -> RhymePrecision {
        return rhymePrecisionSegmentedControl.selectedSegmentIndex == 0 ? .precise : .nonPrecise
    }
    
    func selectedSortOrder() -> SortOrder {
        return rhymeSortOrderSegmentedControl.selectedSegmentIndex == 0 ? .alphabetical : .random
    }
}
