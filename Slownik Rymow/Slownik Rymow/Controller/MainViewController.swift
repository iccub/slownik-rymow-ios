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
    
    var rhymeDefinitionManager = RhymeDefinitionManager()
    var rhymeFinderManager = RhymeFinderManager()
    
    //MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        inputWord.delegate = self
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
        showAlert(setSearchForRhymesAlertMessage(), title: "Szukam rymów", withActivityIndicator: true, cancellable: false)
        
        rhymeFinderManager.getRhymesWithParameters(SearchParameters(word: self.inputWord.text!.lowercaseString, sortMethod: setSortOrderParam(), rhymePrecision: setRhymePrecisionParam(), rhymeLenght: Int(self.rhymeCountStepper.value))) {
            status in
            
            
            switch status {
            case .Failure(let error):
                print("error")
                self.dismissViewControllerAnimated(true) {
                    switch error {
                    case .NotConnectedToNetworkError:
                        self.showAlert("Słownik nie działa w trybie offline. Sprawdź swoje połączenie z internetem", title: "Błąd połączenia", withActivityIndicator: false, cancellable: true)
                    case .EmptyResults:
                        self.showAlert("Brak rymów do słowa \(self.inputWord.text!)", title: "Brak wyników", withActivityIndicator: false, cancellable: true)
                    default:
                        print("default clause, should never launch")
                        
                    }
                    
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
    
    func setSearchForRhymesAlertMessage() -> String {
        return rhymePrecisionSegmentedControl.selectedSegmentIndex == RhymePrecisionSelectedButtonEnum.PreciseRhymes.rawValue ? "" : "Szukanie rymów niedokładnych zajmuje więcej czasu"
    }
    
    func setRhymePrecisionParam() -> String {
        print(RhymePrecisionSelectedButtonEnum.init(rawValue: 0)) // to daje dobry enum
        
        return rhymePrecisionSegmentedControl.selectedSegmentIndex == RhymePrecisionSelectedButtonEnum.PreciseRhymes.rawValue ? "D" : "N"
        
    }
    
    func setSortOrderParam() -> String {
        return rhymeSortOrderSegmentedControl.selectedSegmentIndex == SortMethodSelectedButtonEnum.Alphabetical.rawValue ? "A" : "R"
        
    }
    
    //MARK: Alerts
    
    func showAlert(message: String, title: String, withActivityIndicator: Bool, cancellable: Bool) {
        let pending = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        var views = [String : UIView]()
        
        if withActivityIndicator == true {
            let indicator = UIActivityIndicatorView()
            indicator.translatesAutoresizingMaskIntoConstraints = false
            pending.view.addSubview(indicator)
            indicator.userInteractionEnabled = false
            indicator.startAnimating()
            
            views = ["pending" : pending.view, "indicator" : indicator]
            var constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[indicator]-(-50)-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[indicator]|", options: [], metrics: nil, views: views)
            pending.view.addConstraints(constraints)
        }
        
        if cancellable {
            pending.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        }
        
        self.presentViewController(pending, animated: true, completion: nil)
    }
    
    func showFormattedAlert(message: String, title: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Left
        
        let messageText = NSMutableAttributedString(
            string: message,
            attributes: [
                NSParagraphStyleAttributeName: paragraphStyle,
                NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1),
                NSForegroundColorAttributeName : UIColor.blackColor()
            ]
        )
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.setValue(messageText, forKey: "attributedMessage")
        
        alert.addAction(UIAlertAction(title: "Copy word", style: UIAlertActionStyle.Default) {
            _ in
            UIPasteboard.generalPasteboard().string = title
            }
        )
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
}







