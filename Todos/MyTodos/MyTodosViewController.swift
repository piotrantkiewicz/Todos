import UIKit

class MyTodosViewController: UIViewController {
    
    @IBOutlet weak var addListBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: [TodoList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addListBtn.setCornerRadius(14)
        
        dataSource = myTodoList()
        configureTableView()
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        let cellName = "TodoListCell"
        tableView.register(UINib(nibName: cellName, bundle: nil), forCellReuseIdentifier: cellName)
        tableView.rowHeight = 44
    }
    
    func present(with todoList: TodoList) {
        let todoListViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "TodoListViewController") as! TodoListViewController
        
        todoListViewController.todoList = todoList
        
        present(todoListViewController, animated: true)
    }
    
    private func myTodoList() -> [TodoList] {
        var lists = [TodoList]()
        
        lists.append(TodoList(
            title: "Groceries",
            image: .avocadoIcon,
            color: .greenTodo,
            items: groceriesItems()
        ))
        
        lists.append(TodoList(
            title: "Vacation",
            image: .vacationIcon,
            color: .redTodo,
            items: vacationItems()
        ))
        
        lists.append(TodoList(
            title: "House Chores",
            image: .choresIcon,
            color: .blueTodo,
            items: choresItems()
        ))
        
        return lists
    }
    
    private func groceriesItems() -> [String] {
        var items = [String]()
        items.append("Whole wheat bread")
        items.append("Almond milk")
        items.append("Eggs")
        items.append("Beans")
        
        return items
    }
    
    private func vacationItems() -> [String] {
        var list = [String]()
        list.append("Check weather")
        list.append("Accommodation")
        
        return list
    }
    
    private func choresItems() -> [String] {
        var list = [String]()
        list.append("Vacuum the living room")
        list.append("Clean windows in the dining area")
        list.append("Mop kitchen floors")
        
        return list
    }

    @IBAction func addTapped(_ sender: Any) {
        let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "AddListViewController") as! AddListViewController
        
        viewController.didSaveList = { [weak self] todoList in
            self?.dataSource.insert(todoList, at: 0)
            self?.tableView.reloadData()
        }
        
        present(viewController, animated: true)
    }
}

extension MyTodosViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodoListCell") as? TodoListCell
        else { return UITableViewCell() }
        
        let todoList = dataSource[indexPath.row]
        
        cell.configure(with: todoList)
        cell.selectionStyle = .none
        
        return cell
    }
}

extension MyTodosViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todoList = dataSource[indexPath.row]
        present(with: todoList)
    }
}
