import UIKit
import FirebaseFirestore

class AddEditViewController: UIViewController {

    @IBOutlet weak var tbTaskName: UITextField!
    @IBOutlet weak var switchPriority: UISwitch!
    @IBOutlet weak var lblHeadingLabel: UILabel!
    
    
    var taskToEdit:Task?
    var isInEditMode:Bool = false
    
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if (isInEditMode == true) {
            lblHeadingLabel.text = "Edit Current Task"
            tbTaskName.text = taskToEdit?.name
            switchPriority.isOn = taskToEdit!.isHighPriority
        }
        else {
            lblHeadingLabel.text = "Add New Task"
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        // 1. get the value in the text box
        let userTaskNameInput = tbTaskName.text!
        // 2. get the value in the switch
        let userPriorityInput = switchPriority.isOn
        
        
        let taskToAdd = Task(name: userTaskNameInput, isHighPriority: userPriorityInput)
        
        if (isInEditMode == true) {
            // update the document in FS
            do {
                try db.collection("tasks").document(self.taskToEdit!.id!).setData(from: taskToAdd)
                print("Task updated")
            }
            catch{
                print("Error when updating task in FS")
                print(error)
            }
        }
        else {
            // add the document
            // send this object to FS
            do {
                try db.collection("tasks").addDocument(from: taskToAdd)
                print("Task saved!")
            }
            catch {
                print("Error when saving document")
                print(error)
            }
            
            // clear all the text boxes and prepare for new input
            tbTaskName.text = ""
            switchPriority.isOn = false
        }
    }
}
