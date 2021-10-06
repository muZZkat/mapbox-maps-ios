import XCTest
@testable import MapboxMaps

class GlobeTests: MapViewIntegrationTestCase {

    func testDefaultProjection() {
        guard let mapboxMap = mapView?.mapboxMap else {
            XCTFail("Failed to initialize MapboxMap.")
            return
        }
        verifyProjection(mapboxMap: mapboxMap, expected: .mercator)
    }

    func testGlobeProjectionLowZoom() {
        transitionTest(zoom: MapProjection.transitionZoomLevel - 2.0, expectedProjection: .globe)
    }

    func testGlobeProjectionHighZoom() {
        transitionTest(zoom: MapProjection.transitionZoomLevel + 2.0, expectedProjection: .mercator)
    }

    func testGlobeProjectionTransitionZoom() {
        transitionTest(zoom: MapProjection.transitionZoomLevel, expectedProjection: .mercator)
    }

    func transitionTest(zoom: CGFloat, expectedProjection: MapProjection) {
        guard let mapboxMap = mapView?.mapboxMap else {
            XCTFail("Failed to initialize MapboxMap.")
            return
        }
        mapboxMap.setProjection(mode: .globe)
        mapboxMap.setCamera(to: .init(zoom: zoom))

        let expectation = self.expectation(description: "Wait for map to load")
        mapboxMap.onNext(.mapLoaded) { [weak self] _ in
            self?.verifyProjection(mapboxMap: mapboxMap, expected: expectedProjection)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func verifyProjection(mapboxMap: MapboxMap, expected: MapProjection) {
        do {
            let projection = try mapboxMap.getMapProjection()
            XCTAssertEqual(projection, expected)
        } catch {
            XCTFail("Failed to encode Light.")
        }
    }

}
