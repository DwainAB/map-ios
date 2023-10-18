// MapView.swift
import SwiftUI
import GoogleMaps

//UIViewRepresentable permet de récupérer des composant d'UIKit
struct MapView: UIViewRepresentable {
    var startCoordinate: CLLocationCoordinate2D?
    var endCoordinate: CLLocationCoordinate2D?
    var pathPoints: [CLLocationCoordinate2D]?

    //La première vue est une carte vierge
    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView()
        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        mapView.clear() // Effacez tout ce qui est affiché sur la carte précédemment

        //stock tous les points de passage dans path
        if let points = pathPoints, !points.isEmpty {
            let path = GMSMutablePath()
            for point in points {
                path.add(point)
            }

            //créer la ligne de passage avec une épaisseur de 3.O et l'affiche sur la map
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 3.0
            polyline.map = mapView

            //Permet de centrer sur le point de passage et ajoute un padding de 50.0 pour mieux voir
            let bounds = GMSCoordinateBounds(path: path)
            mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))

            // Ajoutez un marqueur pour le point de départ
            let startMarker = GMSMarker(position: points.first!)
            startMarker.icon = GMSMarker.markerImage(with: .red)
            startMarker.map = mapView

            // Ajoutez un marqueur pour le point d'arrivée
            let endMarker = GMSMarker(position: points.last!)
            endMarker.icon = GMSMarker.markerImage(with: .green)
            endMarker.map = mapView
        }
    }

}
