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
    private let initialUnit: UserPreferredTemperatureUnit

    init(userPreferences: UserPreferencesRepository) {
        self.userPreferences = userPreferences
        self.selectedUnit = userPreferences.preferredTemperatureUnit
        self.initialUnit = userPreferences.preferredTemperatureUnit
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
                        save()
                    }
                    .disabled(selectedUnit == initialUnit)
                }
            }
        }
    }

    private func save() {
        userPreferences.preferredTemperatureUnit = selectedUnit
        dismiss()
    }
}
