//
//  FavouritesViewController+DragDrop.swift
//  Weather
//
//  Created by Romain Rabouan on 7/28/25.
//

import UIKit

extension FavouritesViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        itemsForBeginning session: any UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem] {
        guard let item = dataSource.diffableDataSource.itemIdentifier(for: indexPath) else { return [] }

        let itemProvider = NSItemProvider(object: NSString(string: item.identifier))
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        
        return [dragItem]
    }

    func collectionView(
        _ collectionView: UICollectionView,
        performDropWith coordinator: any UICollectionViewDropCoordinator
    ) {
        guard
            let presenter,
            coordinator.proposal.operation == .move,
            let item = coordinator.items.first,
            let sourceIndexPath = item.sourceIndexPath,
            let destinationIndexPath = coordinator.destinationIndexPath,
            let draggedItem = item.dragItem.localObject as? FavouriteViewDescriptor
        else {
            return
        }

        var currentItems = presenter.state.currentItems
        currentItems.remove(at: sourceIndexPath.item)
        currentItems.insert(draggedItem, at: destinationIndexPath.item)

        dataSource.content = .init(items: currentItems)

        coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        presenter.reorderFavourites(newOrder: currentItems)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        dropSessionDidUpdate session: any UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}
