//
//  LoginViewController.swift
//  PeakPerformance
//
//  Created by Bren on 17/07/2016.
//  Copyright © 2016 Bren. All rights reserved.
//

import UIKit
import Firebase
import SwiftValidator //https://github.com/jpotts18/SwiftValidator

/**
    Protocol for specifying log in DataService requirements.
 */
protocol LogInDataService
{
    func loadUser( uid: String ) -> User
}


/**
    Class that controls the Log In view.
 */
class LoginViewController: UIViewController {
 
    // MARK: - Properties
    
    /// The currently authenticated user.
    var currentUser: User?
    
    /// This view controller's DataService instance.
    let dataService = DataService( )
    
    /// This view controller's SwiftValidator instance.
    let validator = Validator( )
    
    
    // MARK: - Outlets
    
    
    
    // MARK: - Actions
    
    
    
    
    // MARK: - Methods
    /*
    /// Method required by ValidationDelegate (part of SwiftValidator). Is called when all registered fields pass validation.
    func validationSuccessful()
    {
        print ("validation successful")
        self.signUp()
    }
    
    /// Method required by ValidationDelegate (part of SwiftValidator). Is called when a registered field fails against a validation rule.
    func validationFailed(errors: [(Validatable, ValidationError)]) {
        print ("validation failed")
    }
    */
    
    /// Attempts to authenticate a user using supplied details.
    func login()
    {
        
        //Validate fields here somewhere.
        
        FIRAuth.auth()?.signInWithEmail( userNameField.text!, password: passwordField.text!, completion:  {
            user, error in
            
            if let error = error
            {
                //notify user of bad input/error somewhere here
                print("error logging in: " + error.localizedDescription)
            }
            else
            {
                print("logged in")
                if let user = FIRAuth.auth( )?.currentUser
                {
                    let uid = user.uid as String
                    self.currentUser = self.dataService.loadUser( uid )
                }
                
            }
        })
        //self.performSegueWithIdentifier( "loggedIn", sender: self )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loggedIn"
        {
            let dvc = segue.destinationViewController as! TabBarViewController
            dvc.currentUser = self.currentUser
        }
        else if segue.identifier == "signUp"
        {
            //let dvc = segue.destinationViewController as! SignUpViewController
        }
    } */
    

}
