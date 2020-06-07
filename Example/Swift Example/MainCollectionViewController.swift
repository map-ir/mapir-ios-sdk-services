//
//  MainCollectionViewController.swift
//  MapirServices Swift Example
//
//  Created by Alireza Asadi on 25/1/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import UIKit

var services: [Service] = [
    Service(title: "Reverse Geocode", icon: UIImage(systemName: "mappin"), storyboardSegueID: "ShowGeocoderViewController"),
    Service(title: "Search", icon: UIImage(systemName: "magnifyingglass"), storyboardSegueID: "ShowSearchViewController"),
    Service(title: "Static Map", icon: UIImage(systemName: "crop"), storyboardSegueID: "ShowMapSnapshotterViewController"),
    Service(title: "Directions", icon: UIImage(systemName: "car.fill"), storyboardSegueID: "ShowDirectionsTableViewController"),
    Service(title: "Geofence", icon: UIImage(systemName: "hexagon"), storyboardSegueID: "ShowGeofenceTableViewController"),
    Service(title: "Geocode", icon: UIImage(systemName: "map.fill")),
    Service(title: "Distance Matrix", icon: UIImage(systemName: "table.fill")),

]

class MainCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.topItem?.title = "Services"

        configureCollectionView()
    }

    func configureCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
    }

    private func columnCount(for width: CGFloat) -> Int {
        switch width {
        case ..<600: return 2
        case 600..<900: return 4
        case 1000...: return 6
        default: return 2
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ServiceCell.reuseIdentifier, for: indexPath)  as! ServiceCell

        cell.iconView.image = icon(forRowAt: indexPath)
        cell.titleLabel.text = title(forRowAt: indexPath)
        if let tintColor = tintColorForTitleLabelAndIcon(forRowAt: indexPath) {
            cell.iconView.tintColor = tintColor
            cell.titleLabel.textColor = tintColor
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let selectedService = service(forRowAt: indexPath)
        if let segueID = selectedService.storyboardSegueID {
            performSegue(
                withIdentifier: segueID,
                sender: collectionView.cellForItem(at: indexPath))
        } else {
            showAlert(title: "Error", message: "This service does not have example yet. Please try other exmples.")
        }
    }
}

extension MainCollectionViewController {
    func icon(forRowAt indexPath: IndexPath) -> UIImage? {
        service(forRowAt: indexPath).icon
    }

    func title(forRowAt indexPath: IndexPath) -> String? {
        service(forRowAt: indexPath).title
    }

    func tintColorForTitleLabelAndIcon(forRowAt indexPath: IndexPath) -> UIColor? {
        service(forRowAt: indexPath).storyboardSegueID == nil ? .lightGray : nil
    }

    private func service(forRowAt indexPath: IndexPath) -> Service {
        services[indexPath.row]
    }
}

extension MainCollectionViewController {
    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { (section, environment) -> NSCollectionLayoutSection? in
            let columnCount = self.columnCount(for: environment.container.effectiveContentSize.width)

            let itemWidthDimension = NSCollectionLayoutDimension.fractionalWidth(1.0 / CGFloat(columnCount))
            let itemSize = NSCollectionLayoutSize(widthDimension: itemWidthDimension,
                                                  heightDimension: .fractionalHeight(1.0))

            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: itemWidthDimension)

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
            return section
        }
    }
}
