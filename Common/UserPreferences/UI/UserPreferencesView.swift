//
//  UserPreferencesView.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import SwiftUI

struct UserPreferencesView: View {
    @State private var selectedUnit: UserPreferredTemperatureUnit
    @Environment(\.dismiss) var dismiss

    private let userPreferences: UserPreferencesRepository

    init(userPreferences: UserPreferencesRepository) {
        self.userPreferences = userPreferences
        self.selectedUnit = userPreferences.preferredTemperatureUnit
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Temperature Unit", selection: $selectedUnit) {
                    ForEach(UserPreferredTemperatureUnit.allCases, id: \.rawValue) { unit in
                        Text(unit.title)
                            .tag(unit)
                    }
                }
                .pickerStyle(.menu)
            }
            .navigationTitle("Preferences")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveUnit()
                    }
                }
            }
        }
    }

    private func saveUnit() {
        userPreferences.preferredTemperatureUnit = selectedUnit
        dismiss()
    }
}
