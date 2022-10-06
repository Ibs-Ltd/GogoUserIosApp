//
//  CreditViewController.swift
//  Driver
//
//  Created by MAC on 30/03/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class CreditViewController: BaseTableViewController<BaseData> {

    override func viewDidLoad() {
        super.viewDidLoad()
createNavigationLeftButton(NavigationTitleString.credit)
        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "cell")!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

}
