//
//  locationTextField.swift
//  On The Map
//
//  Created by Matthew Dean Furlo on 6/22/15.
//  Copyright (c) 2015 FurloBros. All rights reserved.
//

import Foundation
import UIKit

class locationTextField: NSObject, UITextFieldDelegate {
    
    //this variable is used to make sure the text is deleted only the first time a textfield is selected. It won't keep clearing the text everytime the text field is selecetd.
    var firstEdit = true
    
    //clear the text the first time the text field is selected.
    func textFieldDidBeginEditing(textField: UITextField) {
        if firstEdit {
            textField.text = ""
            firstEdit = false
        }
    }
    
    //turn off the keyboard when the return key is hit.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
    
}
