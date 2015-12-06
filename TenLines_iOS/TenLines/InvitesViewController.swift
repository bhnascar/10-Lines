//
//  InvitesViewController.swift
//  TenLines
//
//  Created by Ben-han on 11/30/15.
//  Copyright © 2015 Art Attack. All rights reserved.
//

import UIKit

class InvitesViewController: UITableViewController {
    
    /* List of invites you've received. */
    private var invites: Array<Sketch>?
    
    /* List of public drawings to join */
    private var anonymous: Array<Sketch>?
    
    /* Switch for displaying invites vs public drawings. */
    @IBOutlet weak var inviteSwitch: UISegmentedControl!
    
    @IBAction func onSwitchSelected(sender: AnyObject) {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup refresh callback.
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refreshInvites:", forControlEvents: UIControlEvents.ValueChanged)
        
        // Setup background color.
        self.view.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None

        // Test account manager.
        ({ AccountManager.sharedManager.getSketches() } ~> {})
        
        // Load invites right away.
        self.refreshInvites(nil)
    }
    
    func refreshInvites(sender: AnyObject?) {
        ({
            self.invites = AccountManager.sharedManager.getInvites()
            self.anonymous = AccountManager.sharedManager.getPublicSketches()
        }
        ~>
        {
            // Hide the loading indicator since we're done loading.
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        })
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (inviteSwitch.selectedSegmentIndex == 0) {
            return (invites == nil) ? 0 : invites!.count
        }
        else {
            return (anonymous == nil) ? 0 : anonymous!.count
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (inviteSwitch.selectedSegmentIndex == 0) {
            return "Sketch with friends!"
        }
        else {
            return "Sketch with the public!"
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label: UILabel = UILabel()
        label.backgroundColor = UIColor.clearColor()
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name: "Avenir Book", size: 17)
        label.textColor = UIColor.lightGrayColor()
        label.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        return label
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        
        // Configure the cell...
        let iconImageView: UIImageView = cell.viewWithTag(100) as! UIImageView
        cell.backgroundColor = UIColor.clearColor()
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = 50
        iconImageView.layer.borderWidth = 4
        iconImageView.layer.borderColor = UIColor(red: 0.6, green: 0.93, blue: 0.85, alpha: 1.0).CGColor
        
        // Get invite.
        var invite: Sketch = invites![indexPath.row]
        if (inviteSwitch.selectedSegmentIndex == 0) {
            invite = invites![indexPath.row]
        }
        else {
            invite = anonymous![indexPath.row]
        }
        
        // Name label.
        let nameLabel: UILabel = cell.viewWithTag(11) as! UILabel
        if (inviteSwitch.selectedSegmentIndex == 0) {
            nameLabel.text = invite.creator! + " invited you!"
        }
        else {
            nameLabel.text = "Created by " + invite.creator!
        }
        
        // Preview picture.
        iconImageView.image = UIImage(named: "sketch_placeholder.png")
        if (invite.image != nil) {
            iconImageView.image = invite.image
        }
        else {
            { invite.loadImage() } ~> { if (invite.image != nil) { iconImageView.image = invite.image } }
        }
        
        // Set acessory view based on selection state.
        let selectedRows = tableView.indexPathsForSelectedRows
        if (selectedRows != nil && selectedRows!.contains(indexPath)) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "loadSketch") {
            let path = self.tableView.indexPathForSelectedRow
            
            // Load sketch.
            let invite = invites![path!.row]
            let whiteboardController = segue.destinationViewController as! WhiteboardViewController
            whiteboardController.sketch = invite
        }
    }
}