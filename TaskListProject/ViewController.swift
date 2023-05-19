import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // var tasks:[String] = ["Do homework", "Walk the dog", "Go to the movies"]
    var tasks:[Task] = []
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        // segue to screen #2
        guard let screen2VC = storyboard?.instantiateViewController(identifier: "Screen2") as? AddEditViewController else {
            print("Error")
            return
        }
        
        screen2VC.isInEditMode = false
        show(screen2VC, sender:self)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        // get the current item we want to display
        let currTask = self.tasks[indexPath.row]
        cell.textLabel?.text = currTask.name
        
        if (currTask.isHighPriority == true) {
            cell.detailTextLabel?.text = "High Priority"
        }
        else {
            cell.detailTextLabel?.text = "Low Priority"
        }
        
        return cell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row clicked!")
        
        guard let screen2VC = storyboard?.instantiateViewController(identifier: "Screen2") as? AddEditViewController else {
            print("Error")
            return
        }

        screen2VC.taskToEdit = self.tasks[indexPath.row]
        screen2VC.isInEditMode = true
        
        show(screen2VC, sender:self)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 1. get the current task
            let currTask = self.tasks[indexPath.row]
            print("We are going to delete: \(currTask.name). This doc has id of \(currTask.id)")
            
            // Delete the task from Firestore
            db.collection("tasks").document(currTask.id!).delete {
                (error) in
                if let err = error {
                    print("Error when deleting document")
                    print(err)
                }
                else {
                    print("Document deleted")
                    // 2. remove it from the tasks array
                    self.tasks.remove(at:indexPath.row)
                    
                    // 3. remove it from the table view
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }

    
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }


    override func viewDidAppear(_ animated: Bool) {
        // clear the existing task list
        tasks.removeAll()
        
        // get the data from FS
        db.collection("tasks").getDocuments {
            (queryResults, error) in
            
            if let err = error {
                print("Error retrieving documents from FS")
                print(err)
            }
            else {
                for document in queryResults!.documents {
                    print(document.documentID)
                    print(document.data())
                    do {
                        let taskFromFS = try document.data(as: Task.self)
                        self.tasks.append(taskFromFS)
                    }
                    catch{
                        print("Error converting document to Task object")
                        print(error)
                    }
                }
                print("Done adding tasks from FS to our app")
                print("Number of tasks converted: \(self.tasks.count)")
                print("Refreshing tableview with new data")
                self.tableView.reloadData()
            }
        }
    }
}

