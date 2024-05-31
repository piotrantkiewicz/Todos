import UIKit

struct TodoList {
    let title: String
    let image: String
    let color: UIColor
    var items: [String]
    
    init(title: String, image: String, color: UIColor, items: [String]) {
        self.title = title
        self.image = image
        self.color = color
        self.items = items
    }
}

class TodoListViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var imageBackgroundView: UIView!
    @IBOutlet private weak var headerView: UIView!
    
    @IBOutlet private weak var addNewItemView: UIView!
    @IBOutlet private weak var addNewItemSafeAreaView: UIView!
    @IBOutlet weak var addNewItemSaveAreaViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var plusBtn: UIButton!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet weak var textFieldLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var addBtn: UIButton!
    
    var todoList: TodoList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageBackgroundView.setCornerRadius(20)
        
        configure()
        configureTableView()
        configureKeyboard()
        configureAddItemView()
        configureTextField()
        
        setAddNewItemButton(enabled: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureTextField() {
        textField.addTarget(self, action: #selector(didChangeText), for: .editingChanged)
    }
    
    private var isNewItemValid: Bool {
        guard let text = textField.text else { return false }
        return !text.isEmpty
    }
    
    @objc private func didChangeText() {
        setAddNewItemButton(enabled: isNewItemValid)
    }
    
    private func setAddNewItemButton(enabled isEnabled:Bool) {
        addBtn.isPointerInteractionEnabled = isEnabled
        addBtn.tintColor = isEnabled ? .accent : UIColor(hex: "#737373")?.withAlphaComponent(0.5)
    }
    
    private func configureAddItemView() {
        addNewItemView.layer.masksToBounds = false
        addNewItemView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        addNewItemView.layer.cornerRadius = 15
        addNewItemView.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        addNewItemView.layer.shadowOffset = .zero
        addNewItemView.layer.shadowRadius = 18.5
        addNewItemView.layer.shadowPath = UIBezierPath(roundedRect: addNewItemView.bounds, cornerRadius: addNewItemView.layer.cornerRadius).cgPath
        addNewItemView.layer.shadowOpacity = 1
        
        addNewItemSafeAreaView.setCornerRadius(15)
    }
    
    private func configureKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        let animationCurveRawNumber = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNumber?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        let isKeyboardHidden = endFrame.origin.y >= UIScreen.main.bounds.size.height
        
        if isKeyboardHidden {
            addNewItemSaveAreaViewBottomConstraint.constant = 0
            textFieldLeftConstraint.constant = 48
        } else {
            addNewItemSaveAreaViewBottomConstraint.constant = -endFrame.height + view.safeAreaInsets.bottom - 8
            textFieldLeftConstraint.constant = 16
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: animationCurve) {
            self.plusBtn.alpha = isKeyboardHidden ? 1 : 0
            self.addBtn.alpha = isKeyboardHidden ? 0 : 1
            self.view.layoutIfNeeded()
        }
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        let cellName = "TodoListItemCell"
        tableView.register(UINib(nibName: cellName, bundle: nil), forCellReuseIdentifier: cellName)
    }
    
    private func configure() {
        titleLbl.text = todoList.title
        iconImageView.image = UIImage(named: todoList.image)
        headerView.backgroundColor = todoList.color
    }
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func plusBtnTapped(_ sender: Any) {
        textField.becomeFirstResponder()
    }
    
    @IBAction func addBtnTapped(_ sender: Any) {
        guard isNewItemValid, let text = textField.text else { return }
        
        let itemTrimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        todoList.items.append(itemTrimmed)
        
        let indexPath = IndexPath(row: todoList.items.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        textField.text = ""
        setAddNewItemButton(enabled: false)
    }
}

extension TodoListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todoList.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodoListItemCell") as? TodoListItemCell
        else { return UITableViewCell() }
        
        let item = todoList.items[indexPath.row]
        cell.configure(with: item)
        
        return cell
    }
}

extension TodoListViewController: UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}
