import UIKit

protocol TodoListRepository {
    func fetchTodoLists() async throws -> [TodoList]
    func addTodoList(_ todoList: TodoList) async throws -> String
    func updateTodoList(_ todoList: TodoList) async throws
    func deleteTodoList(with id: String) async throws
    func addItem(to todoList: TodoList, item: String) async throws
}

class TodoListRepositoryLive: TodoListRepository {
    
    typealias TodoListResponse = [String: TodoListDTO]
    
    private lazy var todosURL = baseURL.appending(path: "todos.json")
    private let baseURL = URL(string: "https://todos-16ed9-default-rtdb.europe-west1.firebasedatabase.app/")!
    
    func fetchTodoLists() async throws -> [TodoList] {
        
        let request = URLRequest(url: todosURL)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoded = try JSONDecoder().decode(TodoListResponse.self, from: data)
        
        return toDomain(decoded)
    }
    
    func addTodoList(_ todoList: TodoList) async throws -> String {
        var request = URLRequest(url: todosURL)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(todoList.toData)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode(DataBasePOSTResponse.self, from: data)
        
        return decoded.name
    }
    
    func updateTodoList(_ todoList: TodoList) async throws {
        let payloadDictionary: [String: String] = [
            "color": todoList.color.hexStringOrWhite,
            "title": todoList.title,
            "icon": todoList.image
        ]
        
        var request = URLRequest(
            url: baseURL
                .appending(path: "todos")
                .appending(path: todoList.id)
                .appending(path: ".json")
        )
        
        request.httpMethod = "PATCH"
        request.httpBody = try JSONSerialization.data(withJSONObject: payloadDictionary)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode(TodoListDTO.self, from: data)
        
        print("Successfully updated list with id \(todoList.id) \(decoded)")
    }
    
    func deleteTodoList(with id: String) async throws {
        var request = URLRequest(
            url: baseURL
                .appending(path: "todos")
                .appending(path: id)
                .appending(path: ".json")
        )
        
        request.httpMethod = "DELETE"
        
        let _ = try await URLSession.shared.data(for: request)
        
        print("Successfully deleted list with id \(id)")
    }
    
    func addItem(to todoList: TodoList, item: String) async throws {
        var request = URLRequest(
            url: baseURL
                .appending(path: "todos")
                .appending(path: todoList.id)
                .appending(path: "items")
                .appending(path: ".json")
        )
        
        let item = TodoListDTO.Item(
            content: item,
            createDate: Date()
        )
        
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(item)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode(DataBasePOSTResponse.self, from: data)
        
        print("Successfully added an item \(decoded.name)")
    }
    
    private func toDomain(_ todoListRespopnse: TodoListResponse) -> [TodoList] {
        var result = [TodoList]()
        
        for (id, todoListDTO) in todoListRespopnse {
            result.append(todoListDTO
                .toDomain(id: id)
            )
        }
        
        return result
    }
}

extension TodoListDTO {
    func toDomain(id: String) -> TodoList {
        TodoList(
            id: id,
            title: self.title,
            image: icon,
            color: UIColor(hex: color) ?? .clear,
            items: items.toDomain
        )
    }
}

extension TodoList {
    var toData: TodoListDTO {
        TodoListDTO(
            color: color.hexStringOrWhite,
            icon: image,
            title: title,
            items: items.toData
        )
    }
}

extension Dictionary where Key == String, Value == TodoListDTO.Item {
    var toDomain: [TodoListItem] {
        var todoListItems = [TodoListItem]()
        for (key, item) in self {
            let todoListItem = TodoListItem(id: key, content: item.content, createDate: item.createDate)
            todoListItems.append(todoListItem)
        }
        
        return todoListItems
            .sorted(by: { $0.createDate < $1.createDate })
    }
}

extension Array where Element == TodoListItem {
    var toData: [String: TodoListDTO.Item] {
        var dict = [String: TodoListDTO.Item]()
        
        for item in self {
            dict[item.id] = TodoListDTO.Item(
                content: item.content,
                createDate: item.createDate)
        }
    
        return dict
    }
}
