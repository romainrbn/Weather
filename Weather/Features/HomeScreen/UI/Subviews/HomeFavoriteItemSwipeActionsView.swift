//
//  HomeFavoriteItemSwipeActionsView.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import SwiftUI

struct HomeFavoriteItemSwipeActionsView: View {
    var body: some View {
        Group {
            Button {} label: {
                Label("Pin", systemImage: "mappin.circle")
            }
            .tint(.blue)

            Button {} label: {
                Label("Remove from favorites", systemImage: "star.slash.fill")
            }
            .tint(.orange)
        }
    }
}

#Preview {
    HomeFavoriteItemSwipeActionsView()
}
