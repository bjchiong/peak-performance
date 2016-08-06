//
//  MonthlyGoalsViewController.swift
//  PeakPerformance
//
//  Created by Bren on 24/07/2016.
//  Copyright © 2016 derridale. All rights reserved.
//

import UIKit


/**
 Class that controls the weekly goals view.
 */
class MonthlyGoalsViewController: UITableViewController, MonthlyGoalDetailViewControllerDelegate {
    
    // MARK: - Properties
    
    /// The currently authenticated user.
    var currentUser: User?
    
    /// This view controller's data service.
    var dataService = DataService( )
    
    // MARK: - UI Variables
    @IBOutlet weak var progressBarMG: UIProgressView!
    
    
    // MARK: - Actions
    
    @IBAction func editButtonPressed(sender: AnyObject)
    {
        self.tableView.setEditing(tableView.editing != true, animated: true)
    }
    
    @IBAction func addButtonPressed(sender: AnyObject)
    {
        performSegueWithIdentifier(ADD_MONTHLY_GOAL_SEGUE, sender: self)
    }
    
    
    @IBAction func unwindFromMGDVC( segue: UIStoryboardSegue ){ }
    
    
    // MARK: - Methods
    
    func addNewGoal( monthlyGoal: MonthlyGoal )
    {
        guard let cu = currentUser else
        {
            //user not available? handle it here
            return
        }
        cu.monthlyGoals.append(monthlyGoal)
        dataService.saveGoal(cu.uid, goal: monthlyGoal)
    }
    
    func saveModifiedGoal(monthlyGoal: MonthlyGoal )
    {
        guard let cu = currentUser else
        {
            //user not available handle it HANDLE IT!
            return
        }
        dataService.saveGoal(cu.uid, goal: monthlyGoal)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        //Get data from tab bar view controller
        let tbvc = self.tabBarController as! TabBarViewController
        
        guard let cu = tbvc.currentUser else
        {
            //no user fix it man, goddamn you fix it what do i pay you for?!?!
            return
        }
        self.currentUser = cu
        tableView.reloadData( )
        print("MGVC: got user \(currentUser!.email) with \(cu.monthlyGoals.count) monthly goals") //DEBUG
        
        //disable editing in case user left view while in edit mode
        self.tableView.setEditing(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return currentUser!.monthlyGoals.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("monthlyGoalCell", forIndexPath: indexPath)
        let goal = currentUser!.monthlyGoals[indexPath.row]
        
        // Configure the cell...
        cell.textLabel!.text = goal.goalText //whatever we want the goal to be called
        cell.textLabel!.font = UIFont.boldSystemFontOfSize(12.0)
        
        //TODO: set image as KLA icon
        /*
         //var klaIcon =
         let kla = goal.kla
         switch kla
         {
         case KLA_FAMILY:
         klaIcon = familyIcon
         
         etc.
         
         }
         */
        
        //TODO: add checkbox in here somewhere
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete
        {
            // Delete the row from the data source
            guard let cu = self.currentUser else
            {
                //no user! wuh oh!
                return
            }
            dataService.removeGoal(cu.uid, goal: cu.monthlyGoals[indexPath.row])
            cu.monthlyGoals.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        else if editingStyle == .Insert
        {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ADD_MONTHLY_GOAL_SEGUE
        {
            let dvc = segue.destinationViewController as! MonthlyGoalDetailViewController
            dvc.delegate = self
            dvc.currentUser = self.currentUser
        }
        else if segue.identifier == EDIT_MONTHLY_GOAL_SEGUE
        {
            let dvc = segue.destinationViewController as! MonthlyGoalDetailViewController
            dvc.delegate = self
            dvc.currentUser = self.currentUser
            if let indexPath = self.tableView.indexPathForSelectedRow
            {
                dvc.currentGoal = currentUser!.monthlyGoals[indexPath.row]
            }
        }
    }
    
    
}

