//
//  HomeFavoriteItemSwipeActionsView.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import SwiftUI

struct HomeFavoriteItemSwipeActionsView: View {
    private let onRemoveFavorite: () -> Void

    init(onRemoveFavorite: @escaping () -> Void) {
        self.onRemoveFavorite = onRemoveFavorite
    }

    var body: some View {
        Group {
            Button {
                onRemoveFavorite()
            } label: {
                Label("Remove from favorites", systemImage: "trash")
            }
            .tint(.red)
        }
    }
}
