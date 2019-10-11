import UIKit
import Apollo


class PostTaskViewController: UITableViewController {
  var tasks: [AllTasksQuery.Data.AllTask]? {
    didSet {
      tableView.reloadData()
    }
  }
  
  // MARK: - View lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 64
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    deleteSubscription()
    addSubscription()
    loadData()
  }
  
  // MARK: - Data loading
  
  var watcher: GraphQLQueryWatcher<AllTasksQuery>?
  
  func loadData() {
    watcher = apollo.watch(query: AllTasksQuery()) { result in
      switch result {
      case .success(let graphQLResult):
        
        self.tasks = graphQLResult.data?.allTasks as? [AllTasksQuery.Data.AllTask]
      case .failure(let error):
        NSLog("Error while fetching query: \(error.localizedDescription)")
      }
    }
  }
  
  // MARK: - UITableViewDataSource
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tasks?.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? PostTableViewCell else {
      fatalError("Could not dequeue PostTableViewCell")
    }
    
    guard let task = tasks?[indexPath.row] else {
      fatalError("Could not find post at row \(indexPath.row)")
    }
    
    cell.configure(with: task.fragments.taskFields)
    
    return cell
  }
  
  @IBAction func addTask(_ sender: UIButton) {
    self.performSegue(withIdentifier: "AddTaskSegue", sender: self)
    
  }
  
  // MARK: - Subscriptions
  
  func deleteSubscription(){
    apollo.subscribe(subscription: DeleteSubscription()) { result in
      self.watcher?.refetch()
    }
  }
  
  func addSubscription(){
    apollo.subscribe(subscription: AddSubscription()) { result in
      self.watcher?.refetch()
    }
  }
  
}


