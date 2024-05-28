import UIKit

struct TodoListDTO: Codable {
    let color: String
    let icon: String
    let title: String
    let items: [String]
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.color = try container.decode(String.self, forKey: .color)
        self.icon = try container.decode(String.self, forKey: .icon)
        self.title = try container.decode(String.self, forKey: .title)
        self.items = try container.decodeIfPresent([String].self, forKey: .items) ?? []
    }
}

class TodoListRepository {
    
    typealias TodoListResponse = [String: TodoListDTO]
    
    func fetchTodoLists() async throws -> [TodoList] {
        let url = URL(string: "https://todos-16ed9-default-rtdb.europe-west1.firebasedatabase.app/todos.json")!
        
        let request = URLRequest(url: url)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoded = try JSONDecoder().decode(TodoListResponse.self, from: data)
        
        return toDomain(decoded)
    }
    
    private func toDomain(_ todoListRespopnse: TodoListResponse) -> [TodoList] {
        var result = [TodoList]()
        
        for (_, todoListDTO) in todoListRespopnse {
            result.append(todoListDTO.toDomain)
        }
        
        return result
    }
}

extension TodoListDTO {
    var toDomain: TodoList {
        TodoList(
            title: self.title,
            image: UIImage(named: icon + "Icon") ?? UIImage(),
            color: UIColor(hex: color) ?? .clear,
            items: items
        )
    }
}
