import UIKit

class MyTodosViewModel {
    
    private let repository: TodoListRepository
    
    var todoLists: [TodoList] = []
    
    var didFetchLists: (() -> ())
    
    init(repository: TodoListRepository = TodoListRepositoryLive(), didFetchLists: @escaping (() -> ())) {
        self.repository = repository
        self.didFetchLists = didFetchLists
    }
    
    func fetchTodos() {
        Task {
            do {
                let result = try await repository.fetchTodoLists()
                self.todoLists = result.sorted(by: { $0.title < $1.title })
                
                await MainActor.run {
                    self.didFetchLists()
                }
            } catch {
                print(error)
            }
        }
    }
    
    func addTodoList(_ todoList: TodoList) {
        todoLists.insert(todoList, at: 0)
        todoLists = todoLists.sorted(by: { $0.title < $1.title })
        
        Task {
            do {
                let id = try await repository.addTodoList(todoList)
                print("Created new list with id \(id)")
            } catch {
                print("Couldn't create a new list")
            }
        }

    }
}
