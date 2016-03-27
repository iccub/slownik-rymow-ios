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
            alertFactory?.showErrorAlert(.NotConnectedToNetworkError)
            return
        }
        
        rhymeDefinitionManager.getRhymeDefinition(foundRhymes[row]) { status in
            switch status {
            case .Failure(let error):
                self.alertFactory?.showErrorAlert(error, word: self.foundRhymes[row])
            case .Success(let rhymeDefinition):
                self.inputWord.resignFirstResponder()
                self.alertFactory?.showFormattedAlert(rhymeDefinition, title: self.foundRhymes[row])
            }
        }
    }
}
