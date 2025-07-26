//
//  UserPreferencesView.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import SwiftUI

struct UserPreferencesView: View {
    @State private var selectedUnit: UserPreferredTemperatureUnit = .systemDefault

    @State private var isSavingNewUnit: Bool = false

    @Environment(\.dismiss) var dismiss

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
                    if isSavingNewUnit {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Button("Save") {
                            isSavingNewUnit = true
                            defer {
                                isSavingNewUnit = false
                            }
                            print("Save Unit")
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    UserPreferencesView()
}
