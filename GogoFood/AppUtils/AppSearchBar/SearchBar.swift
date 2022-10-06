//
//  SearchBar.swift
//  GogoFood
//
//  Created by MAC on 19/02/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit
import SpeechRecognizerButton

class SearchBar: BaseAppView {

    @IBOutlet weak var searchView: UITextField!
    @IBOutlet weak var speechBtn: SFButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchView.placeholder = "What do you want to eat?".localized()
        //self.searchView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup("SearchBar")
    }
    
    @IBAction func tapOnVoiceButton(_ sender: UIButton) {
        
    }
}
