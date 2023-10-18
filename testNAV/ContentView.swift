import SwiftUI
import CoreLocation
import SwiftyJSON
import GoogleMaps // Assurez-vous d'avoir importé le SDK Google Maps

struct ContentView: View {
    @State private var startAddress: String = ""
    @State private var endAddress: String = ""
    @State private var startCoordinate: CLLocationCoordinate2D? = nil
    @State private var endCoordinate: CLLocationCoordinate2D? = nil
    @State private var showMap: Bool = false
    @State private var walkingDuration: String = ""
    @State private var pathPoints: [CLLocationCoordinate2D] = [] // Marquer avec @State
    @State private var citySuggestions: [String] = []
    @State private var errorMessage: String?


    var body: some View {
        //ZStack permet de superposer les éléments
        ZStack {
            // La carte en arrière-plan
            if showMap {
                MapView(startCoordinate: startCoordinate, endCoordinate: endCoordinate, pathPoints: pathPoints)
                    .edgesIgnoringSafeArea(.all) // Permet à la carte de remplir tout l'écran
            }
            
            // conteneur vertical
            VStack(spacing: 20) {
                TextField("Adresse de départ", text: $startAddress)
                    .padding()
                    .background(Color.gray.opacity(0.7))
                    .cornerRadius(8.0)
                    .foregroundColor(.white)
                
                TextField("Adresse d'arrivée", text: $endAddress)
                    .padding()
                    .background(Color.gray.opacity(0.7))
                    .cornerRadius(8.0)
                    .foregroundColor(.white)
                
                Button(action: {
                    geocodeAddresses()
                }) {
                    Text("Obtenir l'itinéraire")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8.0)
                }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
                
                // Afficher le temps de trajet piéton
                if showMap {
                    RoundedRectangle(cornerRadius: 8.0)
                        .fill(Color.blue.opacity(0.7))
                        .frame(height: 40)
                        .overlay(
                            Text("Temps de trajet en marchant : \(walkingDuration)")
                                .foregroundColor(.white)
                        )
                        .padding([.leading, .trailing])
                }
            }
            .padding()
        }
    }
    
    func geocodeAddresses() {
        let geocoder = CLGeocoder()
        
        //transforme l'adresse que l'utilisateur a mis en coordonnées géographiques
        geocoder.geocodeAddressString(startAddress) { (startPlacemarks, startError) in
            if let startPlacemark = startPlacemarks?.first, let startLocation = startPlacemark.location {
                startCoordinate = startLocation.coordinate
            } else {
                DispatchQueue.main.async {
                    errorMessage = "Erreur lors de la géolocalisation de l'adresse de départ."
                }
            }
            
            geocoder.geocodeAddressString(endAddress) { (endPlacemarks, endError) in
                if let endPlacemark = endPlacemarks?.first, let endLocation = endPlacemark.location {
                    endCoordinate = endLocation.coordinate
                } else {
                    DispatchQueue.main.async {
                        errorMessage = "Erreur lors de la géolocalisation de l'adresse d'arrivée."
                    }
                }
                
                // Une fois les coordonnées geocoder, on affiche la carte et le  temps de trajet
                getWalkingDirections()
            }
        }
    }

    func getWalkingDirections() {
        
        //si startCoordinate et endCoordinate on une valeur on continue le code sinon le le code s'arrete et le else s'effectue
        guard let startCoord = startCoordinate, let endCoord = endCoordinate else {
            errorMessage = "Impossible d'obtenir les coordonnées de départ ou d'arrivée."
            return
        }

        let apiKey = "AIzaSyCcHi1ecNpboccjwuOcx0eN92gZu59Avyw"
        let origin = "\(startCoord.latitude),\(startCoord.longitude)"
        let destination = "\(endCoord.latitude),\(endCoord.longitude)"
        let mode = "walking" // "walking" pour les itinéraires piéton

        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=\(mode)&key=\(apiKey)"

        pathPoints.removeAll() // on vide le tableau avant de le remplir avec les nouveaux points

        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                if let data = data {
                    do {
                        let json = try JSON(data: data)
                        let routes = json["routes"].arrayValue

                        if let firstRoute = routes.first {
                            let overviewPolyline = firstRoute["overview_polyline"]["points"].stringValue
                            let decodedPath = GMSPath(fromEncodedPath: overviewPolyline)
                            DispatchQueue.main.async {
                                for index in 0..<decodedPath!.count() {
                                    pathPoints.append(decodedPath!.coordinate(at: index))
                                }

                                let legs = firstRoute["legs"].arrayValue
                                if let firstLeg = legs.first {
                                    let duration = firstLeg["duration"]["text"].stringValue
                                    walkingDuration = duration
                                }

                                // Afficher la carte après avoir obtenu le temps de trajet et les points de l'itinéraire
                                showMap = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    showMap = true
                                }
                            }
                        }
                    } catch {
                        // Gestion des erreurs d'analyse JSON
                        DispatchQueue.main.async {
                            errorMessage = "Erreur lors de l'analyse des données de l'itinéraire."
                        }
                        print(error)
                    }
                } else if let error = error {
                    // Gestion des erreurs de requête
                    DispatchQueue.main.async {
                        errorMessage = "Erreur lors de la récupération de l'itinéraire."
                    }
                    print(error)
                }
            }.resume()
        }
    }

}
