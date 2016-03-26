//
//  MainViewController+TableDelegate.swift
//  Slownik Rymow
//
//  Created by Michal Buczek on 25.03.2016.
//  Copyright © 2016 Michał Buczek. All rights reserved.
//

import UIKit

extension MainViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let row = indexPath.row
        
        guard Reachability.isConnectedToNetwork() else {
            showAlert("Słownik nie działa w trybie offline. Sprawdź swoje połączenie z internetem", title: "Błąd połączenia", withActivityIndicator: false, cancellable: true)
            return
        }
        
        RhymeDefinitionModel.getRhymeDefinition(foundRhymes[row]) { status in
            switch status {
            case .Failure(let error):
                switch error {
                case .EmptyResults:
                    self.showAlert("Brak definicji w słowniku", title: self.foundRhymes[row], withActivityIndicator: false, cancellable: true)
                case .NotConnectedToNetworkError:
                    self.showAlert("Słownik nie działa w trybie offline. Sprawdź swoje połączenie z internetem", title: "Błąd połączenia", withActivityIndicator: false, cancellable: true)
                default:
                    print("default clause to satisfy enum, should never launch")
                }
            case .Success(let rhymeDefinition):
                self.inputWord.resignFirstResponder()
                self.showFormattedAlert(rhymeDefinition, title: self.foundRhymes[row])
            }
        }
    }
}
