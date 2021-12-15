import UIKit

internal protocol PinchGestureHandlerProtocol: GestureHandler {
    var rotateEnabled: Bool { get set }
    var behavior: PinchGestureBehavior { get set }
}

internal protocol PinchGestureHandlerImpl: AnyObject {
    func handleGesture(_ gestureRecognizer: UIPinchGestureRecognizer, state: UIGestureRecognizer.State)
}

/// `PinchGestureHandler` updates the map camera in response to a 2-touch
/// gesture that may consist of translation, scaling, and rotation
internal final class PinchGestureHandler: GestureHandler, PinchGestureHandlerProtocol {
    /// Whether pinch gesture can rotate map or not
    internal var rotateEnabled: Bool = true {
        didSet {
            impl1.rotateEnabled = rotateEnabled
            impl2.rotateEnabled = rotateEnabled
        }
    }

    internal var behavior: PinchGestureBehavior = .tracksTouchLocationsWhenPanningAfterZoomChange

    private var initialBehavior: PinchGestureBehavior?

    private let impl1: PinchGestureHandlerImpl1

    private let impl2: PinchGestureHandlerImpl2

    public var panEnabled: Bool = false
    public var rotateEnabled: Bool = false
    public var didZoom: Bool = false
    public var didRotate: Bool = false

    /// Initialize the handler which creates the panGestureRecognizer and adds to the view
    internal init(gestureRecognizer: UIPinchGestureRecognizer,
                  mapboxMap: MapboxMapProtocol) {
        self.impl1 = PinchGestureHandlerImpl1(mapboxMap: mapboxMap)
        self.impl2 = PinchGestureHandlerImpl2(mapboxMap: mapboxMap)
        super.init(gestureRecognizer: gestureRecognizer)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
        impl1.delegate = self
        impl2.delegate = self
    }

    @objc private func handleGesture(_ gestureRecognizer: UIPinchGestureRecognizer) {
        guard let view = gestureRecognizer.view else {
            return
        }
        let pinchMidpoint = panEnabled ? gestureRecognizer.location(in: view) : mapboxMap.anchor
        let effectiveBehavior: PinchGestureBehavior?
        let state = gestureRecognizer.state

        switch state {
        case .began:
            effectiveBehavior = behavior
            initialBehavior = behavior
        case .changed:

            // UIPinchGestureRecognizer sends a .changed event when the number
            // of touches decreases from 2 to 1. If this happens, we pause our
            // gesture handling.
            //
            // if a second touch goes down again before the gesture ends, we
            // resume and re-capture the initial state (except for zoom since
            // UIPinchGestureRecognizer provides continuity of scale values)
            guard gestureRecognizer.numberOfTouches == 2 else {
                initialPinchMidpoint = nil
                initialPinchAngle = nil
                initialCenter = nil
                initialBearing = nil
                return
            }
            guard let initialZoom = initialZoom else {
                return
            }
            // Using explicit self to help out older versions of Xcode (pre-12.5) to figure out the scope of these variables here. Bug: https://bugs.swift.org/browse/SR-8669
            let pinchAngle = self.pinchAngle(with: gestureRecognizer)
            guard let initialPinchMidpoint = initialPinchMidpoint,
                  let initialPinchAngle = initialPinchAngle,
                  let initialCenter = initialCenter,
                  let initialBearing = initialBearing else {
                self.initialPinchMidpoint = pinchMidpoint
                self.initialPinchAngle = pinchAngle
                self.initialCenter = mapboxMap.cameraState.center
                self.initialBearing = mapboxMap.cameraState.bearing
                return
            }
            
            let zoomIncrement = log2(gestureRecognizer.scale)
            if zoomIncrement > 0.1 || zoomIncrement < -0.1 {
                didZoom = true
            }
            
            var cameraOptions = CameraOptions()
            cameraOptions.center = initialCenter
            cameraOptions.zoom = initialZoom
            cameraOptions.bearing = initialBearing

            mapboxMap.setCamera(to: cameraOptions)

            if panEnabled {
                mapboxMap.dragStart(for: initialPinchMidpoint)
                let dragOptions = mapboxMap.dragCameraOptions(
                    from: initialPinchMidpoint,
                    to: pinchMidpoint)
                mapboxMap.setCamera(to: dragOptions)
                mapboxMap.dragEnd()
            }
            
            var rotationInDegrees = 0.0
            if rotateEnabled && (!didZoom || didRotate) {
                // the two angles will always be in the range [0, 2pi)
                // so the resulting rotation will be in the range (-2pi, 2pi)
                var rotation = pinchAngle - initialPinchAngle
                // if the rotation is negative, add 2pi so that the final
                // result is in the range [0, 2pi)
                if rotation < 0 {
                    rotation += 2 * .pi
                }
                // convert from radians to degrees and flip the sign since
                // the iOS coordinate system is flipped relative to the
                // coordinate system used for bearing in the map.
                rotationInDegrees = Double(rotation * 180.0 / .pi * -1)
                
                if  rotationInDegrees > -5.0 && rotationInDegrees < 5.0 {
                    rotationInDegrees = 0
                } else {
                    didRotate = true
                }
                
            }
            
            mapboxMap.setCamera(
                to: CameraOptions(
                    anchor: pinchMidpoint,
                    zoom: initialZoom + zoomIncrement,
                    bearing: initialBearing + rotationInDegrees))
        case .ended, .cancelled:
            initialPinchMidpoint = nil
            initialPinchAngle = nil
            initialCenter = nil
            initialZoom = nil
            initialBearing = nil
            didZoom = false
            didRotate = false
            delegate?.gestureEnded(for: .pinch, willAnimate: false)
            effectiveBehavior = initialBehavior
        default:
            effectiveBehavior = nil
        }

        let impl: PinchGestureHandlerImpl?

        switch effectiveBehavior {
        case .tracksTouchLocationsWhenPanningAfterZoomChange:
            impl = impl1
        case .doesNotResetCameraAtEachFrame:
            impl = impl2
        default:
            impl = nil
        }

        impl?.handleGesture(gestureRecognizer, state: state)
    }
}

extension PinchGestureHandler: GestureHandlerDelegate {
    func gestureBegan(for gestureType: GestureType) {
        delegate?.gestureBegan(for: gestureType)
    }

    func gestureEnded(for gestureType: GestureType, willAnimate: Bool) {
        delegate?.gestureEnded(for: gestureType, willAnimate: willAnimate)
    }

    func animationEnded(for gestureType: GestureType) {
        delegate?.animationEnded(for: gestureType)
    }
}
