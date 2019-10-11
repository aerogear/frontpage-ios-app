import UIKit

class AddTaskViewController: UIViewController {
  
  
  @IBOutlet weak var nameField: UITextField!
  
  @IBOutlet weak var descriptionField: UITextField!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    nameField.delegate = self
    descriptionField.delegate = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func addTask(_ sender: UIButton) {
    
    var taskStatus: TaskStatus
    taskStatus = TaskStatus.open
    
    self.performSegue(withIdentifier: "PostListController", sender: self)
    apollo.perform(mutation: CreateTaskMutation(title: nameField.text ?? "test1", description: descriptionField.text ?? "description of test1", status: taskStatus  )) { result in
      switch result {
      case .success:
        break
      case .failure(let error):
        NSLog("Error while attempting to upvote post: \(error.localizedDescription)")
      }
    }
  }
  
  @IBAction func cancel(_ sender: Any) {
    self.performSegue(withIdentifier: "PostListController", sender: self)
  }
  
}

extension AddTaskViewController: UITextFieldDelegate{
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    textField.resignFirstResponder()
    
    return true
  }
}
