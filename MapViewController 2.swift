import UIKit
import GoogleMaps

class MapViewController: UIViewController {

  private var mapView: GMSMapView?
  private var restrooms: [Restroom] = []
  private var filteredRestrooms: [Restroom] = []

  // Filter state
  private var selectedAccessTiers: Set<AccessTier> = Set(AccessTier.allCases)

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "NYC Free Restrooms"
    setupMap()
    setupFilterUI()
    loadRestrooms()
  }

  private func setupMap() {
    let camera = GMSCameraPosition.camera(withLatitude: 40.7128, longitude: -74.0060, zoom: 12)
    mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)

    guard let mapView = mapView else { return }
    mapView.delegate = self
    view.addSubview(mapView)
    view.sendSubviewToBack(mapView)
  }

  private func setupFilterUI() {
    let filterButton = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(showFilterOptions))
    navigationItem.rightBarButtonItem = filterButton
  }

  @objc private func showFilterOptions() {
    let alert = UIAlertController(title: "Filter by Access Type", message: nil, preferredStyle: .actionSheet)

    for tier in AccessTier.allCases {
      let isSelected = selectedAccessTiers.contains(tier)
      let title = (isSelected ? "✓ " : "") + tier.rawValue

      alert.addAction(UIAlertAction(title: title, style: .default) { _ in
        if isSelected {
          self.selectedAccessTiers.remove(tier)
        } else {
          self.selectedAccessTiers.insert(tier)
        }
        self.applyFilters()
      })
    }

    alert.addAction(UIAlertAction(title: "Show All", style: .default) { _ in
      self.selectedAccessTiers = Set(AccessTier.allCases)
      self.applyFilters()
    })

    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

    present(alert, animated: true)
  }

  private func applyFilters() {
    filteredRestrooms = restrooms.filter { selectedAccessTiers.contains($0.accessType) }
    updateMapMarkers()
  }

  private func loadRestrooms() {
    // TODO: Fetch from NYC Open Data API
    // For now, load sample data
    fetchRestrooms()
  }

  private func fetchRestrooms() {
    // Placeholder: Replace with actual API call
    // Example API endpoint: https://data.cityofnewyork.us/api/views/vzrx-zg6z/rows.json?$limit=1000

    // For now, create sample data
    let sampleRestroom = Restroom(
      id: "1",
      name: "Central Park - Restroom",
      latitude: 40.7829,
      longitude: -73.9654,
      hours: "6 AM - 10 PM",
      agency: "Parks",
      accessType: .free,
      adaAccessible: true,
      hasChangingStation: false,
      stalls: 4,
      notes: "Located near the Bethesda Terrace",
      locationType: "Park",
      seasonality: "Year-round"
    )

    restrooms.append(sampleRestroom)
    applyFilters()
  }

  private func updateMapMarkers() {
    mapView?.clear()

    for restroom in filteredRestrooms {
      let marker = GMSMarker()
      marker.position = CLLocationCoordinate2D(latitude: restroom.latitude, longitude: restroom.longitude)
      marker.title = restroom.name
      marker.snippet = restroom.accessType.rawValue

      // Color code by access type
      switch restroom.accessType {
      case .free:
        marker.iconView = createColoredMarker(color: .systemGreen)
      case .courtesy:
        marker.iconView = createColoredMarker(color: .systemBlue)
      case .harder:
        marker.iconView = createColoredMarker(color: .systemRed)
      }

      marker.map = mapView
    }
  }

  private func createColoredMarker(color: UIColor) -> UIView {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
    view.backgroundColor = color
    view.layer.cornerRadius = 16
    return view
  }
}

extension MapViewController: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
    let infoViewController = RestoomInfoViewController()
    // TODO: Pass selected restroom data
    navigationController?.pushViewController(infoViewController, animated: true)
    return true
  }
}
