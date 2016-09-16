//
//  MainViewController+TableDelegate.swift
//  Slownik Rymow
//
//  Created by Michal Buczek on 25.03.2016.
//  Copyright © 2016 Michał Buczek. All rights reserved.
//

import UIKit

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = (indexPath as NSIndexPath).row
        
        guard Reachability.isConnectedToNetwork() else {
            alertFactory?.showErrorAlert(.notConnectedToNetworkError)
            return
        }
        
        rhymeDefinitionManager.getRhymeDefinition(foundRhymes[row]) { status in
            switch status {
            case .failure(let error):
                self.alertFactory?.showErrorAlert(error, word: self.foundRhymes[row])
            case .success(let rhymeDefinition):
                self.inputWord.resignFirstResponder()
                self.alertFactory?.showFormattedAlert(rhymeDefinition, title: self.foundRhymes[row])
            }
        }
    }
}
