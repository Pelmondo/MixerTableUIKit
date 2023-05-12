//
//  ViewController.swift
//  MixerTableUIKit
//
//  Created by Сергей Прокопьев on 11.05.2023.
//

import UIKit

class ViewController: UIViewController {
    private lazy var tableView = UITableView(frame: .zero, style: .insetGrouped)

    var datasource: UITableViewDiffableDataSource<Int, CellItem>!

    var data = CellItem.generateData()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        datasource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, cellItem -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            var config = UIListContentConfiguration.cell()
            config.text = cellItem.id
            cell?.accessoryType = cellItem.isSelected ? .checkmark : .none
            cell?.contentConfiguration = config
            return cell
        })

        createSnapshot()

        view.tintColor = .systemMint
        title = "Task 4"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Shuffle", style: .plain, target: self, action: #selector(shuffleCells)
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemMint

        tableView.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = .init(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: view.frame.height
        )
    }

    private func createSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(data)
        datasource.apply(snapshot, animatingDifferences: true)
    }
}

extension ViewController: UITableViewDelegate { 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard var cellItem = datasource.itemIdentifier(for: indexPath) else {
            return
        }

        var snap = datasource.snapshot()

        if !cellItem.isSelected {
            snap.deleteItems([cellItem])
            guard let first = snap.itemIdentifiers.first else {
                return
            }
            cellItem.isSelected.toggle()
            snap.insertItems([cellItem], beforeItem: first)
        } else {
            let oldItem = cellItem
            cellItem.isSelected.toggle()
            let newItem = cellItem
            snap.insertItems([newItem], beforeItem: oldItem)
            snap.deleteItems([oldItem])
        }
        datasource.apply(snap, animatingDifferences: true)
    }

    @objc func shuffleCells() {
        var snap = datasource.snapshot()
        var indeces = snap.itemIdentifiers
        snap.deleteItems(indeces)
        indeces.shuffle()
        snap.appendItems(indeces)
        datasource.apply(snap, animatingDifferences: true)
    }
}

struct CellItem: Hashable {
    let id: String
    var isSelected: Bool

    static func generateData() -> [CellItem] {
        var array = [CellItem]()
        for i in 0..<43 {
            array.append(.init(id: "\(i)", isSelected: false))
        }
        return array
    }
}
