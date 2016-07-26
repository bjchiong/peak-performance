//
//  SignUpViewController.swift
//  PeakPerformance
//
//  Created by Bren on 17/07/2016.
//  Copyright © 2016 Bren. All rights reserved.
//

import UIKit
import Firebase
import SwiftValidator //https://github.com/jpotts18/SwiftValidator

/*
/**
    Protocol for specifying Sign Up DataService.
 */
protocol SignUpDataService
{
    func saveUser( user: User )
}
*/

/**
    Class that controls the Sign Up view.
 */
class SignUpViewController: UIViewController, ValidationDelegate, UITextFieldDelegate {
    
    // MARK: - Properties
    
    /// The currently authenticated user.
    var currentUser: User?
    
    /// This view controller's DataService instance.
    let dataService = DataService( )
    
    /// This view controller's SwiftValidator instance.
    let validator = Validator( )
    
    
    // MARK: - Outlets
    
    //text fields
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var orgField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    //@IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    
    //labels
    @IBOutlet weak var firstNameErrorLabel: UILabel!
    @IBOutlet weak var lastNameErrorLabel: UILabel!
    @IBOutlet weak var orgErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
   // @IBOutlet weak var userNameErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var confirmPasswordErrorLabel: UILabel!
    @IBOutlet weak var signUpErrorLabel: UILabel!
    
    // MARK: - Actions
    
    @IBAction func signUpButtonPressed(sender: AnyObject)
    {
        //self.signUp()
        validator.validate(self)
    }
    
    
    @IBAction func goToLogIn(sender: AnyObject)
    {
        shouldPerformSegueWithIdentifier(GO_TO_LOG_IN_SEGUE, sender: self )
    }
    
    
    
    // MARK: - Methods
    
    /// Method required by ValidationDelegate (part of SwiftValidator). Is called when all registered fields pass validation.
    func validationSuccessful()
    {
        print ("SUVC: validation successful") //DEBUG
        self.signUp()
    }
    
    /// Method required by ValidationDelegate (part of SwiftValidator). Is called when a registered field fails against a validation rule.
    func validationFailed(errors: [(Validatable, ValidationError)]) {
        print ("SUVC: validation failed") //DEBUG
    }
    
    /// Attempts to create a new Firebase user account with supplied email and password.
    func signUp()
    {
            FIRAuth.auth()?.createUserWithEmail(emailField.text!, password: passwordField.text!, completion: {
                user, error in
                if let error = error
                {
                    //Check for Firebase errors and inform user of error here somewhere
                    print("SUVC: error creating account - " + error.localizedDescription) //DEBUG
                }
                else
                {
                    print("SUVC: account created") //DEBUG
                    self.firstLogin()
                }
            })
    }
    
    //delegate this back to Login VC???
    /// Authenticates the user with the supplied details and if succesfull, creates the user object.
    func firstLogin( )
    {
        FIRAuth.auth()?.signInWithEmail( emailField.text!, password: passwordField.text!, completion:  {
            user, error in
            
            if let error = error
            {
                //Check for Firebase errors and inform user here
                print("SUVC: error logging in - " + error.localizedDescription) //DEBUG
                if let errCode = FIRAuthErrorCode( rawValue: error.code )
                {
                    switch errCode
                    {
                    case .ErrorCodeNetworkError:
                        self.signUpErrorLabel.text = NETWORK_ERR_MSG
                        self.signUpErrorLabel.hidden = false
                        
                    case .ErrorCodeEmailAlreadyInUse:
                        self.signUpErrorLabel.text = EMAIL_IN_USE_ERR_MSG
                        self.signUpErrorLabel.hidden = false
                        
                    default:
                        print("SUVC: error case not currently covered") //DEBUG
                    }
                }

            }
            else
            {
                print("logged in")
                self.createUser( )
                //currently this segue goes to the TabBar view, but this where you would segue to the tutorial/initial setup
                //feel free to change the segue in the storyboard (but keep the segue identifier, or change it here) when it's ready
                self.performSegueWithIdentifier( FT_LOG_IN_SEGUE, sender: self )
            }
        })
        
    }
    
    /// Creates a new user and save details to database.
    func createUser( )
    {
        if let user = FIRAuth.auth( )?.currentUser
        {
            //create new user object
            let fname = self.firstNameField.text!
            let lname = self.lastNameField.text!
            let org = self.orgField.text!
            //let username = self.userNameField.text!
            let email = self.emailField.text!
            let uid = user.uid as String
            
            self.currentUser = User( fname: fname, lname: lname, org: org, email: email, uid: uid, weeklyGoals: [String]() )
            
            self.dataService.saveUser( self.currentUser! )
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        validator.validate(self)
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up SwiftValidator style transformers (modifying the field/error label based on success or failure).
        //This should pretty much stay the same for all controllers and text fields.
        validator.styleTransformers(success: { (validationRule) -> Void in
            validationRule.errorLabel?.hidden = true
            validationRule.errorLabel?.text = ""
            if let textField = validationRule.field as? UITextField
            {
                textField.layer.borderColor = TEXTFIELD_REGULAR_BORDER_COLOUR
                textField.layer.borderWidth = CGFloat( TEXTFIELD_REGULAR_BORDER_WIDTH )
            }
            
            }, error: { (validationError ) -> Void in
                validationError.errorLabel?.hidden = false
                validationError.errorLabel?.text = validationError.errorMessage
                if let textField = validationError.field as? UITextField
                {
                    textField.layer.borderColor = TEXTFIELD_ERROR_BORDER_COLOUR
                    textField.layer.borderWidth = CGFloat( TEXTFIELD_ERROR_BORDER_WIDTH )
                }
            })
        
        //Registering fields to be validated by SwiftValidator.
        //Params for registration are the text field, the label to display the error and an array of validation rules which can also each take an error message as an argument.
        //See "jpotss18.github.io/SwiftValidator" for the docs and various rules.
        //Custom rules can be created but if this framework doesn't work I can build a custom module, but for now it's working pretty good.
        
        //first name field
        validator.registerField(firstNameField, errorLabel: firstNameErrorLabel, rules: [RequiredRule( message: REQUIRED_FIELD_ERR_MSG), AlphaRule( message: ALPHA_CHAR_ERR_MSG)] )
        
        //last name field
        validator.registerField(lastNameField, errorLabel: lastNameErrorLabel, rules: [RequiredRule( message: REQUIRED_FIELD_ERR_MSG), AlphaRule( message: ALPHA_CHAR_ERR_MSG)] )
        
        //org field
        validator.registerField(orgField, errorLabel: orgErrorLabel, rules: [RequiredRule( message: REQUIRED_FIELD_ERR_MSG ), AlphaRule( message: ALPHA_CHAR_ERR_MSG)] )
        
        //email field
        validator.registerField(emailField, errorLabel: emailErrorLabel, rules: [RequiredRule( message: REQUIRED_FIELD_ERR_MSG), EmailRule( message: BAD_EMAIL_ERR_MSG)] )
        
        //username field
        //validator.registerField(userNameField, errorLabel: userNameErrorLabel, rules: [RequiredRule( message: REQUIRED_FIELD_ERR_MSG), AlphaNumericRule( message: ALPHA_NUMERIC_CHAR_ERR_MSG) ] )
        
        //password field
        validator.registerField(passwordField, errorLabel: passwordErrorLabel, rules: [RequiredRule( message: REQUIRED_FIELD_ERR_MSG), MinLengthRule(length: PW_MIN_LEN, message: SHORTPW_ERR_MSG ), MaxLengthRule(length: PW_MAX_LEN, message: LONGPW_ERR_MSG), PasswordRule( message: BADPW_ERR_MSG ) ] )
        
        //confirm password field
        validator.registerField(confirmPasswordField, errorLabel: confirmPasswordErrorLabel, rules: [RequiredRule( message: REQUIRED_FIELD_ERR_MSG), ConfirmationRule( confirmField: passwordField, message: CONPW_ERR_MSG)])
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //hide error labels
        firstNameErrorLabel.hidden = true
        lastNameErrorLabel.hidden = true
        orgErrorLabel.hidden = true
        emailErrorLabel.hidden = true
        //userNameErrorLabel.hidden = true
        passwordErrorLabel.hidden = true
        confirmPasswordErrorLabel.hidden = true
        signUpErrorLabel.hidden = true
    }
    

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //if identifier == "loggedIn" {}
        if segue.identifier == GO_TO_LOG_IN_SEGUE
        {
            let dvc = segue.destinationViewController as! LoginViewController
            dvc.currentUser = self.currentUser
        }
        else if segue.identifier == FT_LOG_IN_SEGUE
        {
            //here is where you would segue to tutorial/inital setup when it's ready
            let dvc = segue.destinationViewController as! TabBarViewController
            dvc.currentUser = self.currentUser
        }
    }
    

}
