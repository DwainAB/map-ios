import SwiftUI
import GoogleMaps

@main //point d'entrée de l'application
struct MyApp: App {

    // Init permet d'initialiser et de configurer tout ce qui est nécessaire avant que l'application ne démarre.
    init() {
        GMSServices.provideAPIKey("AIzaSyD7F2s14_9TklqEblaMIQNOrIpK2GzkbH8")
    }
    
    // La propriété 'body' définit l'interface utilisateur principale de l'application.
    var body: some Scene {
        // WindowGroup crée une nouvelle fenêtre pour afficher le contenu de l'application, ici il affiche la vue 'ContentView'.
        WindowGroup {
            ContentView()
        }
    }
}
