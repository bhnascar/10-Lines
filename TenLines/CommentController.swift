//
//  CommentController.swift
//  TenLines
//
//  Created by Sarah Wymer on 11/19/15.
//  Copyright © 2015 Art Attack. All rights reserved.
//

import UIKit

class CommentController: UIViewController {
    
    @IBOutlet weak var userTextField: UITextField!
    
    @IBOutlet weak var commentField: UITextView!
    
    @IBOutlet weak var CommentCount: UILabel!
    
    @IBOutlet weak var pictureImageView: UIImageView!
    
    @IBOutlet weak var upVoteCount: UILabel!
    
    @IBAction func upVoteButton(sender: AnyObject) {
        if upVoteCount.text == "" {
            upVoteCount.text = "1"
        } else {
            if let myNumber = NSNumberFormatter().numberFromString(upVoteCount.text!) {
                var myInt = myNumber.integerValue
                myInt = myInt + 1
                let myString = String(myInt)
                upVoteCount.text = myString
            } else {
                print("error changing upVoteCount to string")
            }
        }
    }
    
    var pictureURL: String!
    
    @IBAction func sendComment(sender: AnyObject) {
        if userTextField.text != "" {
            commentField.text = "User Name" + "\n" + userTextField.text! + "\n\n" + commentField.text!
            userTextField.text = ""
        
            if let myNumber = NSNumberFormatter().numberFromString(CommentCount.text!) {
                var myInt = myNumber.integerValue
                myInt = myInt + 1
                let myString = String(myInt)
                CommentCount.text = myString
            } else {
                print("error changing CommentCount to string")
            }
        }

    }
    
    override func viewDidLoad() {
        // Setup view.
        self.view.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        self.pictureImageView.layer.masksToBounds = false
        self.pictureImageView.layer.shadowColor = UIColor(white: 0.7, alpha: 1.0).CGColor
        self.pictureImageView.layer.shadowOffset = CGSizeMake(0, 0)
        self.pictureImageView.layer.shadowOpacity = 0.5
        
        // Load image.
        let request: NSURLRequest = NSURLRequest(URL: NSURL(string: pictureURL)!)
        let mainQueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
            if error == nil {
                // Convert the downloaded data in to a UIImage object.
                let image = UIImage(data: data!)
                dispatch_async(dispatch_get_main_queue(), {
                    self.pictureImageView.image = image
                })
            }
            else {
                print("Error: \(error!.localizedDescription)")
            }
        })
    }
}



