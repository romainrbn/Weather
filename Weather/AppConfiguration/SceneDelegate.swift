//
//  SceneDelegate.swift
//  Weather
//
//  Created by Romain Rabouan on 7/25/25.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var favouritesModule: FavouritesModule?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let favouritesModule = FavouritesModule(
            dependencies: FavouriteDependencies(
                citySearchService: WeatherLocalCitySearchService(),
                favouriteStore: LiveFavouriteStore(
                    localRepository: LiveFavouriteLocalRepository(),
                    remoteRepository: LiveFavouriteRemoteRepository()
                ),
                forecastStore: LiveForecastStore(
                    repository: LiveForecastRemoteRepository()
                ),
                preferencesRepository: UserPreferencesRepository()
            )
        )
        self.favouritesModule = favouritesModule
        let navigationController = UINavigationController(rootViewController: favouritesModule.viewController)
        navigationController.navigationBar.prefersLargeTitles = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

