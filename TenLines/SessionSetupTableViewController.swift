//
//  SessionSetupTableViewController.swift
//  TenLines
//
//  Created by Ben-han on 11/14/15.
//  Copyright © 2015 Art Attack. All rights reserved.
//

import UIKit

class SessionSetupTableViewController: UITableViewController {

    @IBOutlet weak var startButton: UIButton!
    
    private var friends: Array<Artist>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up refresh callback.
        self.refreshControl?.addTarget(self, action: "refreshFriends:", forControlEvents: UIControlEvents.ValueChanged)
        
        // Setup background color.
        self.view.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // Programmatically create rounded corners for start button.
        startButton.clipsToBounds = true;
        startButton.layer.cornerRadius = 65;
        
        // Center start button.
        startButton.center = CGPoint.init(x: self.view.frame.width / 2, y: startButton.center.y);
        
        // Load friends right away.
        self.refreshFriends(nil)
        
        self.tableView.allowsMultipleSelection = true;
    }
    
    func refreshFriends(sender: AnyObject?) {
        self.tableView.reloadData()
        
        // Temporary load feed data from a file. Eventually we want to get this
        // data by invoking a web service instead.
        let path = NSBundle.mainBundle().pathForResource("friends", ofType: "json")
        let data = JSON(data: NSData(contentsOfFile: path!)!)
        friends = Artist.fromJSON(data)
        
        // Hide the loading indicator since we're done loading.
        self.refreshControl?.endRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: true);
    }
    
    func addCheckMarkToCell(cell: UITableViewCell, animated: Bool) {
        let iconImageView: UIImageView = cell.viewWithTag(20) as! UIImageView
        
        // Add overlay.
        let overlayView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        overlayView.center = CGPoint(x: iconImageView.frame.size.width / 2, y: iconImageView.frame.size.height / 2)
        overlayView.backgroundColor = UIColor(red: 0.15, green: 0.23, blue: 0.21, alpha: 0.5)
        overlayView.layer.cornerRadius = 50
        overlayView.tag = 100001
        iconImageView.addSubview(overlayView)
        
        // Add check mark.
        let checkmark = UIImageView(image: UIImage(named: "checkmark.png"))
        checkmark.frame = overlayView.bounds
        checkmark.contentMode = UIViewContentMode.Center
        overlayView.addSubview(checkmark)
        
        let duration = (animated) ? 0.3 : 0.0
        UIView.animateWithDuration(duration) {
            overlayView.center = CGPoint(x: iconImageView.frame.size.width / 2, y: iconImageView.frame.size.height / 2)
            overlayView.frame = iconImageView.bounds
            checkmark.frame = overlayView.bounds
        }
    }
    
    func removeCheckMarkFromCell(cell: UITableViewCell, animated: Bool) {
        let iconImageView: UIImageView = cell.viewWithTag(20) as! UIImageView
        let overlayView = iconImageView.viewWithTag(100001)
        // let center = CGPoint(x: iconImageView.frame.size.width / 2, y: iconImageView.frame.size.height / 2)
        
        // Remove checkmark, if it exists.
        if (overlayView != nil) {
            let duration = (animated) ? 0.3 : 0.0
            UIView.animateWithDuration(duration, animations: {
                // TODO
            }, completion: {
                (value: Bool) in
                let _ = iconImageView.subviews.map({subview in subview.removeFromSuperview()})
            })
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "You recently sketched with..."
        }
        else {
            return "All friends"
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.darkGrayColor()
        label.font = UIFont(name: "AmaticSC-Bold", size: 30)
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        return label
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends != nil ? friends!.count : 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath)

        // Configure the cell...
        let iconImageView: UIImageView = cell.viewWithTag(20) as! UIImageView
        cell.backgroundColor = UIColor.clearColor()
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = 50
        iconImageView.layer.borderWidth = 4
        iconImageView.layer.borderColor = UIColor(red: 0.6, green: 0.93, blue: 0.85, alpha: 1.0).CGColor
        
        // Get artist.
        let artist = friends![indexPath.row]
        
        // Name label.
        let nameLabel: UILabel = cell.viewWithTag(10) as! UILabel
        nameLabel.text = artist.firstname
        
        // Profile picture.
        if (artist.icon != nil) {
            iconImageView.image = artist.icon
        }
        else {
            { artist.loadIcon() } ~> { iconImageView.image = artist.icon }
        }
        
        // Set acessory view based on selection state.
        let selectedRows = tableView.indexPathsForSelectedRows
        if (selectedRows != nil && selectedRows!.contains(indexPath)) {
            addCheckMarkToCell(cell, animated: false)
        }
        else {
            removeCheckMarkFromCell(cell, animated: false)
        }

        return cell
    }

    // MARK: - Navigation

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        addCheckMarkToCell(cell!, animated: true)
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        removeCheckMarkFromCell(cell!, animated: true)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
