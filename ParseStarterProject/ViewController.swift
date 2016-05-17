// ViewController

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {

    // Outlets
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var riderLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var `switch`: UISwitch!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var toggleSignupButton: UIButton!
    @IBOutlet weak var phone: UITextField!
    
    var signUpState = true
    
    // Signup
    @IBAction func signUp(sender: AnyObject) {
        
        if (username.text == "" || password.text == "") {
            
            displayAlert("Missing Field(s)", message: "Username and password are required!")
            
        } else {
            
            if signUpState == true {
                
                // Parse Signup
                let user = PFUser()
                user.username = username.text
                user.password = password.text
                
                user["phone"] = phone.text
                user["isDriver"] = `switch`.on
                
                user.signUpInBackgroundWithBlock {
                    (succeeded: Bool, error: NSError?) -> Void in
                    if let error = error {
                        if let errorString = error.userInfo["error"] as? String {
                            
                            self.displayAlert("SignUp Failed", message: errorString)
                        }
                        
                    } else {
                        
                        if self.`switch`.on == true {
                            
                            self.performSegueWithIdentifier("loginDriver", sender: self)
                        } else {
                        
                            self.performSegueWithIdentifier("loginRider", sender: self)
                        }
                    }
                }
            } else {
                
                PFUser.logInWithUsernameInBackground(username.text!, password:password.text!) {
                    (user: PFUser?, error: NSError?) -> Void in
                    if let user = user {
                        
                        if user["isDriver"]! as! Bool == true {
                            
                            self.performSegueWithIdentifier("loginDriver", sender: self)
                        } else {
                            
                            self.performSegueWithIdentifier("loginRider", sender: self)
                        }
                        
                    } else {
                        
                        if let errorString = error!.userInfo["error"] as? String {
                            
                            self.displayAlert("Login Failed", message: errorString)
                        }
                    }
                }
                
            } // login | else ends
            
        } // main else ends
        
    } // Method ends
    
    @IBAction func toggleSignup(sender: AnyObject) {
        
        if signUpState == true {
            
            signUpButton.setTitle("Log In", forState: UIControlState.Normal)
            
            toggleSignupButton.setTitle("Switch to Signup", forState: UIControlState.Normal)
            
            signUpState = false
            
            phone.alpha         = 0
            riderLabel.alpha    = 0
            driverLabel.alpha   = 0
            `switch`.alpha      = 0
            
        } else {
            
            signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
            
            toggleSignupButton.setTitle("Switch to Login", forState: UIControlState.Normal)
            
            signUpState = true
            
            phone.alpha         = 1
            riderLabel.alpha    = 1
            driverLabel.alpha   = 1
            `switch`.alpha      = 1
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.username.delegate = self
        self.password.delegate = self
    }
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }


    // Helper Methods
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // Dismiss Keyboard upon return key-press
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser()?.username != nil {
            
            if PFUser.currentUser()?["isDriver"]! as! Bool == true {
                
                self.performSegueWithIdentifier("loginDriver", sender: self)
            } else {
                
                self.performSegueWithIdentifier("loginRider", sender: self)
            }

        }
    }
    
    
    
    
    
    
}
