//
//  ListTableViewController.swift
//  ViperTaskManager
//
//  Created by Aaron Lee on 19/11/16.
//  Copyright © 2016 One Fat Giraffe. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftFetchedResultsController


class ListTableViewController: UITableViewController {
    
    let kProjectTableViewCellReuseIdentifier = "ProjectTableViewCellReuseIdentifier"

    
    // MARK: - VIPER Properties
    var presenter: ListPresenterProtocol!


    var projectFetchedResultsController: FetchedResultsController<ProjectEntity>!
    var projects: [Project] = []
    
    override var nibName: String? {
        get {
            let classString = String(self.dynamicType)
            return classString
        }
    }
    override var nibBundle: NSBundle? {
        get {
            return NSBundle.mainBundle()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "ProjectTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: kProjectTableViewCellReuseIdentifier)
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.rowHeight = UITableViewAutomaticDimension
        
//        self.navigationItem.rightBarButtonItems!.append(self.editButtonItem())
        self.navigationItem.rightBarButtonItems = []
        self.navigationItem.rightBarButtonItems!.append(self.editButtonItem())
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.presenter.fetchProjects() { (result: [Project]) -> Void in
            self.projects = result
            self.tableView.reloadData()
        }
        
        // TODO refactor to comply with VIPER
        //        let realm = try! Realm()
        //        let predicate = NSPredicate(format: "projectId != %@", "0")
        //        let fetchRequest = FetchRequest<TaskEntity>(realm: realm, predicate: predicate)
        //        let sortDescriptor = SortDescriptor(property: "name", ascending: true)
        //        fetchRequest.sortDescriptors = [sortDescriptor]
        //        self.taskFetchedResultsController = FetchedResultsController<TaskEntity>(fetchRequest: fetchRequest, sectionNameKeyPath: nil, cacheName: nil)
        //        self.taskFetchedResultsController!.delegate = self
        //        self.taskFetchedResultsController!.performFetch()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return projects.count
        
        default:
            fatalError("Wrong section")
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Project List"
        default:
            fatalError("Wrong section")
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(kProjectTableViewCellReuseIdentifier, forIndexPath: indexPath) as! ProjectTableViewCell
            cell.project = projects[indexPath.row]
            return cell
            
        default:
            fatalError("Wrong indexPath")
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            let project = projects[indexPath.row]
            self.presenter.showDetailProject(project)

        default:
            fatalError("Wrong section")
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            switch indexPath.section {
            case 0:
                let project = projects[indexPath.row]
                self.presenter.removeProject(project) { (error) -> Void in
                    if (error == nil) {
                        self.projects.removeAtIndex(indexPath.row)
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    } else {
                        print("delete project error")
                    }
                }
                

            default:
                fatalError("Wrong section")
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }

    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return false
    }

    @IBAction func add(sender: AnyObject) {
        let alert = UIAlertController(title: "New Project",
                                      message: "Type in a name",
                                      preferredStyle: UIAlertControllerStyle.Alert)
        
        let ok = UIAlertAction(title: "OK",
                               style: UIAlertActionStyle.Default) { (action: UIAlertAction) in
                                
            if let alertTextField = alert.textFields?.first where alertTextField.text != nil {
                
                print("And the text is... \(alertTextField.text!)!")
                self.presenter.addNewProject(alertTextField.text!)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel",
                                   style: UIAlertActionStyle.Cancel,
                                   handler: nil)
        
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) in
            textField.placeholder = ""
        }
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension ListTableViewController: ListInterfaceProtocol {
    
}

extension ListTableViewController: AddViewControllerDelegate {
    
    func addViewControllerDidSelectProject(project: Project) {
        projects.append(project)
        self.tableView.reloadData()
    }
}
