import UIKit
import MapboxMaps

/**
 NOTE: This view controller should be used as a scratchpad
 while you develop new features. Changes to this file
 should not be committed.
 */

public class DebugViewController: UIViewController {

    internal var mapView: MapView!
    internal let sourceIdentifier = "route-source-identifier"
    internal var routeLineSource: GeoJSONSource!
    var currentIndex = 0

    public var geoJSONLine = (identifier: "routeLine", source: GeoJSONSource())

    override public func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(latitude: 45.5076, longitude: -122.6736)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate,
                                                                  zoom: 11.0))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Wait for the map to load its style before adding data.
        mapView.mapboxMap.onNext(.mapLoaded) { _ in

            self.addLine()
        }
    }
    
    var animationFrameCounter = 1

    func addLine() {

        // Create a GeoJSON data source.
        routeLineSource = GeoJSONSource()
        routeLineSource.data = .feature(Feature(geometry: .lineString(LineString(allCoordinates))))
        routeLineSource.lineMetrics = true

        // Create a line layer
        var lineLayer = LineLayer(id: "line-layer")
        lineLayer.source = sourceIdentifier
        lineLayer.lineColor = .constant(StyleColor(.red))
        lineLayer.lineGradient = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.lineProgress)
                0
                UIColor.white
                0.1
                UIColor.black
                1.0
                UIColor.black
            }
        )
        
        Timer.scheduledTimer(withTimeInterval: 1.0/8.0, repeats: true) { [weak self] timer in
            
            guard let self = self else { return }
        
            let newExp = Exp(.interpolate) {
                Exp(.linear)
                Exp(.lineProgress)
                self.makeStops()
            }
            
            let jsonObject = try! JSONSerialization.jsonObject(
                with: try! JSONEncoder().encode(newExp),
                options: [])
            
            try! self.mapView.mapboxMap.style.setLayerProperty(for: "line-layer", property: "line-gradient", value: jsonObject)
            
            if self.animationFrameCounter < 5 {
                self.animationFrameCounter += 1
            } else {
                self.animationFrameCounter = 1
            }
        }

        let lowZoomWidth = 5
        let highZoomWidth = 20

        // Use an expression to define the line width at different zoom extents
        lineLayer.lineWidth = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                14
                lowZoomWidth
                18
                highZoomWidth
            }
        )
        lineLayer.lineCap = .constant(.round)
        lineLayer.lineJoin = .constant(.round)

        // Add the lineLayer to the map.
        try! mapView.mapboxMap.style.addSource(routeLineSource, id: sourceIdentifier)
        try! mapView.mapboxMap.style.addLayer(lineLayer)
    }
    
    func makeStops() -> [Double: UIColor] {
        guard animationFrameCounter <= 5 && animationFrameCounter > 0 else {
            fatalError()
        }
        
        var stops: [Double: UIColor] = [:]
        
        if animationFrameCounter == 1 {
            stops = [
                0: .white,
                0.3: .black
            ]
        } else if animationFrameCounter == 2 {
            stops = [
                0: .black,
                0.3: .white,
                0.6: .black
            ]
        } else if animationFrameCounter == 3 {
            stops = [
                0.3: .black,
                0.6: .white,
                0.9: .black
            ]
        } else if animationFrameCounter == 4 {
            stops = [
                0.6: .black,
                0.9: .white,
                1.0: .black
            ]
        } else if animationFrameCounter == 5 {
            stops = [
                0.7: .black,
                1.0: .white
            ]
        }
        
        return stops
    }

    let allCoordinates = [
        CLLocationCoordinate2D(latitude: 45.52214, longitude: -122.63748),
        CLLocationCoordinate2D(latitude: 45.52218, longitude: -122.64855),
        CLLocationCoordinate2D(latitude: 45.52219, longitude: -122.6545),
        CLLocationCoordinate2D(latitude: 45.52196, longitude: -122.65497),
        CLLocationCoordinate2D(latitude: 45.52104, longitude: -122.65631),
        CLLocationCoordinate2D(latitude: 45.51935, longitude: -122.6578),
        CLLocationCoordinate2D(latitude: 45.51848, longitude: -122.65867),
        CLLocationCoordinate2D(latitude: 45.51293, longitude: -122.65872),
        CLLocationCoordinate2D(latitude: 45.51295, longitude: -122.66576),
        CLLocationCoordinate2D(latitude: 45.51252, longitude: -122.66745),
        CLLocationCoordinate2D(latitude: 45.51244, longitude: -122.66813),
        CLLocationCoordinate2D(latitude: 45.51385, longitude: -122.67359),
        CLLocationCoordinate2D(latitude: 45.51406, longitude: -122.67415),
        CLLocationCoordinate2D(latitude: 45.51484, longitude: -122.67481),
        CLLocationCoordinate2D(latitude: 45.51532, longitude: -122.676),
        CLLocationCoordinate2D(latitude: 45.51668, longitude: -122.68106),
        CLLocationCoordinate2D(latitude: 45.50934, longitude: -122.68503),
        CLLocationCoordinate2D(latitude: 45.50858, longitude: -122.68546),
        CLLocationCoordinate2D(latitude: 45.50783, longitude: -122.6852),
        CLLocationCoordinate2D(latitude: 45.50714, longitude: -122.68424),
        CLLocationCoordinate2D(latitude: 45.50585, longitude: -122.68433),
        CLLocationCoordinate2D(latitude: 45.50521, longitude: -122.68429),
        CLLocationCoordinate2D(latitude: 45.50445, longitude: -122.68456),
        CLLocationCoordinate2D(latitude: 45.50371, longitude: -122.68538),
        CLLocationCoordinate2D(latitude: 45.50311, longitude: -122.68653),
        CLLocationCoordinate2D(latitude: 45.50292, longitude: -122.68731),
        CLLocationCoordinate2D(latitude: 45.50253, longitude: -122.68742),
        CLLocationCoordinate2D(latitude: 45.50239, longitude: -122.6867),
        CLLocationCoordinate2D(latitude: 45.5026, longitude: -122.68545),
        CLLocationCoordinate2D(latitude: 45.50294, longitude: -122.68407),
        CLLocationCoordinate2D(latitude: 45.50271, longitude: -122.68357),
        CLLocationCoordinate2D(latitude: 45.50055, longitude: -122.68236),
        CLLocationCoordinate2D(latitude: 45.49994, longitude: -122.68233),
        CLLocationCoordinate2D(latitude: 45.49955, longitude: -122.68267),
        CLLocationCoordinate2D(latitude: 45.49919, longitude: -122.68257),
        CLLocationCoordinate2D(latitude: 45.49842, longitude: -122.68376),
        CLLocationCoordinate2D(latitude: 45.49821, longitude: -122.68428),
        CLLocationCoordinate2D(latitude: 45.49798, longitude: -122.68573),
        CLLocationCoordinate2D(latitude: 45.49805, longitude: -122.68923),
        CLLocationCoordinate2D(latitude: 45.49857, longitude: -122.68926),
        CLLocationCoordinate2D(latitude: 45.49911, longitude: -122.68814),
        CLLocationCoordinate2D(latitude: 45.49921, longitude: -122.68865),
        CLLocationCoordinate2D(latitude: 45.49905, longitude: -122.6897),
        CLLocationCoordinate2D(latitude: 45.49917, longitude: -122.69346),
        CLLocationCoordinate2D(latitude: 45.49902, longitude: -122.69404),
        CLLocationCoordinate2D(latitude: 45.49796, longitude: -122.69438),
        CLLocationCoordinate2D(latitude: 45.49697, longitude: -122.69504),
        CLLocationCoordinate2D(latitude: 45.49661, longitude: -122.69624),
        CLLocationCoordinate2D(latitude: 45.4955, longitude: -122.69781),
        CLLocationCoordinate2D(latitude: 45.49517, longitude: -122.69803),
        CLLocationCoordinate2D(latitude: 45.49508, longitude: -122.69711),
        CLLocationCoordinate2D(latitude: 45.4948, longitude: -122.69688),
        CLLocationCoordinate2D(latitude: 45.49368, longitude: -122.69744),
        CLLocationCoordinate2D(latitude: 45.49311, longitude: -122.69702),
        CLLocationCoordinate2D(latitude: 45.49294, longitude: -122.69665),
        CLLocationCoordinate2D(latitude: 45.49212, longitude: -122.69788),
        CLLocationCoordinate2D(latitude: 45.49264, longitude: -122.69771),
        CLLocationCoordinate2D(latitude: 45.49332, longitude: -122.69835),
        CLLocationCoordinate2D(latitude: 45.49334, longitude: -122.7007),
        CLLocationCoordinate2D(latitude: 45.49358, longitude: -122.70167),
        CLLocationCoordinate2D(latitude: 45.49401, longitude: -122.70215),
        CLLocationCoordinate2D(latitude: 45.49439, longitude: -122.70229),
        CLLocationCoordinate2D(latitude: 45.49566, longitude: -122.70185),
        CLLocationCoordinate2D(latitude: 45.49635, longitude: -122.70215),
        CLLocationCoordinate2D(latitude: 45.49674, longitude: -122.70346),
        CLLocationCoordinate2D(latitude: 45.49758, longitude: -122.70517),
        CLLocationCoordinate2D(latitude: 45.49736, longitude: -122.70614),
        CLLocationCoordinate2D(latitude: 45.49736, longitude: -122.70663),
        CLLocationCoordinate2D(latitude: 45.49767, longitude: -122.70807),
        CLLocationCoordinate2D(latitude: 45.49798, longitude: -122.70807),
        CLLocationCoordinate2D(latitude: 45.49798, longitude: -122.70717),
        CLLocationCoordinate2D(latitude: 45.4984, longitude: -122.70713),
        CLLocationCoordinate2D(latitude: 45.49893, longitude: -122.70774)
    ]
}
