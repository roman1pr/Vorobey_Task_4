//
//  ViewController.swift
//  Vorobey_Task_4
//
//  Created by Roman Priiskalov on 11.09.2023.
//

import UIKit

class DataSourceItem {
    let id = UUID()
    let name: String
    var isChecked: Bool
    
    init(name: String, isChecked: Bool) {
        self.name = name
        self.isChecked = isChecked
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView!
    var dataSource: [DataSourceItem] = Array(1...30).map { DataSourceItem(name: "Cell \($0)" , isChecked: false)} // Исходные данные для ячеек таблицы

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButton()
        setupTableView()

        view.backgroundColor = .systemGray6
    }
    
    private func setupButton() {
        // Создание кнопки перемешивания ячеек
        let shuffleButton = UIButton(frame: CGRect(x: view.frame.width - 120, y: 40, width: 100, height: 40))
        shuffleButton.setTitle("Shuffle", for: .normal)
        shuffleButton.setTitleColor(.blue, for: .normal)
        shuffleButton.addTarget(self, action: #selector(shuffleCells), for: .touchUpInside)
        view.addSubview(shuffleButton)
    }
    
    private func setupTableView() {
        // Создание UITableView
        tableView = UITableView(frame: view.frame, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32)
        ])
        
        tableView.layer.cornerRadius = 10
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
        cell.textLabel?.text = dataSource[indexPath.row].name
        cell.accessoryType = dataSource[indexPath.row].isChecked ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? Cell else { return }
        
        var item = dataSource[indexPath.row]
        item.isChecked.toggle()
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            cell.accessoryType = item.isChecked ? .checkmark : .none
            
            // Перемещение ячейки на верх с анимацией
            tableView.performBatchUpdates({
                if item.isChecked {
                    self?.dataSource.remove(at: indexPath.row)
                    self?.dataSource.insert(DataSourceItem(name: cell.textLabel?.text ?? "", isChecked: item.isChecked), at: 0)
                    tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
                }
            }, completion: { (_) in
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            })
        }

    }
    
    // MARK: - Button actions
    
    @objc func shuffleCells() {
        tableView.performBatchUpdates {
            var oldPositions: [UUID] = self.dataSource.map({ $0.id })

            self.dataSource.shuffle() // Перемешивание исходных данных для ячеек
            
            var newPositions: [IndexPath] = self.dataSource.compactMap { item in
                oldPositions.firstIndex(where: {$0 == item.id})
            }.map({IndexPath(row: $0, section: 0)})
            
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.tableView.performBatchUpdates ({ [weak self] in
                    
                    guard let self else { return }
                    
                    for (index, newPos) in newPositions.enumerated() {
                        let oldPos = IndexPath(row: index, section: 0)
                        let newData = self.dataSource[index]
                        
                        self.dataSource.remove(at: oldPos.row)
                        self.dataSource.insert(newData, at: newPos.row)
                        tableView.moveRow(at: oldPos, to: newPos)
                    }
                }, completion: { (_) in
                    self?.tableView.reloadData()
                })
            }

        }
    }
}

class Cell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Настройка ячейки
        accessoryType = .none
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
