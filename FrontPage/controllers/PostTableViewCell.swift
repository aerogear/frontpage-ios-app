import UIKit

class PostTableViewCell: UITableViewCell {
  var taskId: String?
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var bylineLabel: UILabel!
  @IBOutlet weak var votesLabel: UILabel!
  @IBOutlet weak var titleAdd: UITextField!
  @IBOutlet weak var descriptionAdd: UITextField!
  
  func configure(with task: TaskFields) {
    taskId = task.id
    titleLabel?.text = task.title
    bylineLabel?.text = task.description
  }
  
  @IBAction func delete() {
    guard let taskId = taskId else { return }
    
    Client.instance.apolloClient.perform(mutation: DeleteTaskMutation(id: taskId)) { result in
      switch result {
      case .success:
        break
      case .failure(let error):
        NSLog("Error while attempting to upvote post: \(error.localizedDescription)")
      }
    }
  }
}
