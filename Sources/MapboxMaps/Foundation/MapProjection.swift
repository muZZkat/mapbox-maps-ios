// Describes the projection used to render the map.
//
// Mapbox map supports Mercator and Globe projections.
public enum MapProjection: String {
    // Mercator projection.
    //
    // Mercator projection description: https://en.wikipedia.org/wiki/Mercator_projection
    case mercator

    // Globe projection is a custom map projection mode for rendering the map wrapped around a full 3D globe.
    // Conceptually it is the undistorted and unskewed “ground truth” view of the map
    // that preserves true proportions between different areas of the map.
    //
    // Some layers are not supported when map is in Globe projection:
    //  - circle
    //  - custom
    //  - fill extrusion
    //  - heatmap
    //  - location indicator
    //
    // If Globe projection is set it will be switched automatically to Mercator projection
    // when passing `MapProjection.transitionZoomLevel` during zooming in.
    //
    // See `MapProjection.transitionZoomLevel` for more details what projection will be used depending on current zoom level.
    case globe

    // Zoom level threshold where MapboxMap will automatically switch projection
    // from `MapProjection.mercator` to `MapProjection.globe` or vice-versa
    // if MapProjectionDelegate.setMapProjection was configured to use `MapProjection.globe`.
    //
    // If MapboxMap is using `MapProjection.globe` and current map zoom level is >= `MapProjection.transitionZoomLevel` -
    // map will use `MapProjection.mercator` and MapProjectionDelegate.getMapProjection will return `MapProjection.mercator`.
    //
    // If MapboxMap is using `MapProjection.globe` and current map zoom level is < `MapProjection.transitionZoomLevel` -
    // map will use `MapProjection.globe` and MapProjectionDelegate.getMapProjection will return `MapProjection.globe`.
    //
    // If MapboxMap is using `MapProjection.mercator` - map will use `MapProjection.mercator` for any zoom level and
    // MapProjectionDelegate.getMapProjection will return `MapProjection.mercator`.
    public static let transitionZoomLevel: CGFloat = 5.0
}
