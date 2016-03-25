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
        
        FoundRhymesModel.getRhymeDefinition(foundRhymes[row] as! String, onCompletion: { (responseObject: String) in
            dispatch_async(dispatch_get_main_queue()) {
                self.showFormattedAlert(responseObject, title: self.foundRhymes[row] as! String)
            }
        })
    }
}
