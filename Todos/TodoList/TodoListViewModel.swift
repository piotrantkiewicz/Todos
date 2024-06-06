import UIKit

class TodoListViewModel {
    
    private let repository: TodoListRepository
    
    var todoList: TodoList!
    
    func isNewItemValid(_ item: String) -> Bool {
        !item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(
        repository: TodoListRepository = TodoListRepositoryLive(),
        todoList: TodoList!
    ) {
        self.repository = repository
        self.todoList = todoList
    }
    
    func update(with todoList: TodoList) {
        self.todoList.update(with: todoList)
        
        Task {
            do {
                try await repository.updateTodoList(self.todoList)
            } catch {
                print(error)
            }
        }
    }
    
    func delete() {
        Task {
            do {
                try await repository.deleteTodoList(with: todoList.id)
            } catch {
                print(error)
            }
        }
    }
    
    func addItem(_ item: String) {
        let itemTrimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
        todoList.items.append(
            TodoListItem(content: item, createDate: Date())
        )
        
        Task {
            do {
                try await repository.addItem(to: todoList, item: item)
            } catch {
                print(error)
            }
        }
    }
}

extension TodoList {
    mutating func update(with todoList: TodoList) {
        title = todoList.title
        color = todoList.color
        image = todoList.image
    }
}
