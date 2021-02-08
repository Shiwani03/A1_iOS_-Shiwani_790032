//
//  ViewController.swift
//  A1_iOS_ Shiwani_790032
//
//  Created by Shiwani on 25/01/21.
//

import UIKit
import MapKit
class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    @IBOutlet weak var map: MKMapView!
    var userLocation : CLLocation?
    var manager = CLLocationManager()
    var pinCoordinates = [CLLocationCoordinate2D]()
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        map.addGestureRecognizer(tapGR)
    }
    @objc func handleTap(_ gesture: UITapGestureRecognizer){
        let touch = gesture.location(in: map)
        let tapLocation = map.convert(touch, toCoordinateFrom: map)
        var title = String()
        if map.annotations.count == 0{
            title = "A"
        }
        else if map.annotations.count == 1{
            title = "B"
        }
        else{
            title = "C"
        }
        if let nearest = map.annotations.closest(to: CLLocation(latitude: tapLocation.latitude, longitude: tapLocation.longitude)){
            map.removeAnnotation(nearest)
            for overlay in map.overlays{
                map.removeOverlay(overlay)
            }
        }
        else{
            if map.annotations.count < 3{
                let annotation  = MKPointAnnotation()
                annotation.title = title
                annotation.coordinate = tapLocation
                map.addAnnotation(annotation)
                if map.annotations.count == 3{
                    let ploygen = MKPolygon(coordinates: map.annotations.map({$0.coordinate}), count: 3)
                    map.addOverlay(ploygen)
                }
            }
            else{
                for overlay in map.overlays{
                    map.removeOverlay(overlay)
                }
                for pin in map.annotations{
                    map.removeAnnotation(pin)
                }
            }
        }
    }
    
    //MARK:-  MAPKIT DELGATES
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let _ = overlay as? MKPolygon{
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red
            rendrer.strokeColor = UIColor.green
            rendrer.alpha = 0.5
            return rendrer
        }
        else if let _ = overlay as? MKPolyline{
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.lineWidth = 4
            rendrer.strokeColor = UIColor.purple
            return rendrer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    //MARK:-  CLLOCATIOM MANAGER DELGATES
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else {return}
        userLocation = loc
        map.region = MKCoordinateRegion(center: userLocation!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    }
    
    
    //Direction Button
    @IBAction func handleDirection(_ sender: Any) {
        if map.annotations.count == 3{
            let coordinateArray = map.annotations.map({$0.coordinate})
            for overlay in map.overlays{
                map.removeOverlay(overlay)
            }
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: coordinateArray[0].latitude, longitude: coordinateArray[0].longitude), addressDictionary: nil))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: coordinateArray[1].latitude, longitude: coordinateArray[1].longitude), addressDictionary: nil))
            request.requestsAlternateRoutes = true
            request.transportType = .automobile
            
            let directions = MKDirections(request: request)
            directions.calculate { (re, err) in
                if err == nil{
                    if let route = re!.routes.first {
                        self.map.addOverlay(route.polyline)
                        self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                    }
                }
            }
            
            let request2 = MKDirections.Request()
            request2.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: coordinateArray[1].latitude, longitude: coordinateArray[1].longitude), addressDictionary: nil))
            request2.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: coordinateArray[2].latitude, longitude: coordinateArray[2].longitude), addressDictionary: nil))
            request2.requestsAlternateRoutes = true
            request2.transportType = .automobile
            
            let directions2 = MKDirections(request: request2)
            directions2.calculate { (re, err) in
                if err == nil{
                    if let route = re!.routes.first {
                        self.map.addOverlay(route.polyline)
                        self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                    }
                }
            }
                let request3 = MKDirections.Request()
                request3.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: coordinateArray[2].latitude, longitude: coordinateArray[2].longitude), addressDictionary: nil))
                request3.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: coordinateArray[0].latitude, longitude: coordinateArray[0].longitude), addressDictionary: nil))
                request3.requestsAlternateRoutes = true
                request3.transportType = .automobile
                
                
                let directions3 = MKDirections(request: request3)
                directions3.calculate { (re, err) in
                    if err == nil{
                        if let route = re!.routes.first {
                            self.map.addOverlay(route.polyline)
                            self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                        }
                    }
                }
            }
            
        }
}
        extension Array where Iterator.Element == MKAnnotation {
            
            func closest(to fixedLocation: CLLocation) -> Iterator.Element? {
                guard !self.isEmpty else { return nil}
                var closestAnnotation: Iterator.Element? = nil
                var smallestDistance: CLLocationDistance = 5000
                for annotation in self {
                    let locationForAnnotation = CLLocation(latitude: annotation.coordinate.latitude, longitude:annotation.coordinate.longitude)
                    let distanceFromUser = fixedLocation.distance(from:locationForAnnotation)
                    if distanceFromUser < smallestDistance {
                        smallestDistance = distanceFromUser
                        closestAnnotation = annotation
                    }
                }
                return closestAnnotation
            }
        }
