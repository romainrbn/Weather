//
//  FavouriteItemSwipeActionsView.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import SwiftUI

struct FavouriteItemSwipeActionsView: View {
    private let onRemoveFavourite: () -> Void

    init(onRemoveFavourite: @escaping () -> Void) {
        self.onRemoveFavourite = onRemoveFavourite
    }

    var body: some View {
        Group {
            Button {
                onRemoveFavourite()
            } label: {
                Label("Remove from favourites", systemImage: "trash")
            }
            .tint(.red)
        }
    }
}
