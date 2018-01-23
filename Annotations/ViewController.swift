//
//  ViewController.swift
//  Annotations
//
//  Created by Suyeol Jeon on 23/01/2018.
//  Copyright © 2018 Suyeol Jeon. All rights reserved.
//

import MapKit
import UIKit

class ViewController: UIViewController {
  let mapView: MKMapView = {
    let view = MKMapView()
    view.register(MyAnnotationView.self, forAnnotationViewWithReuseIdentifier: "pin")
    return view
  }()
  let areaView: UIView = {
    let view = UIView()
    view.layer.borderWidth = 1
    view.layer.borderColor = UIColor.red.cgColor
    view.isUserInteractionEnabled = false
    return view
  }()
  let visibleAnnotationsItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Map"
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .refresh,
      target: self,
      action: #selector(refreshAnnotations)
    )
    self.toolbarItems = [
      UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      self.visibleAnnotationsItem,
      UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
    ]
    self.mapView.delegate = self
    self.view.addSubview(self.mapView)
    self.view.addSubview(self.areaView)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.mapView.frame = self.view.bounds

    self.areaView.frame.size.width = self.view.frame.width - 100
    self.areaView.frame.size.height = 200
    self.areaView.center.x = self.view.frame.width / 2
    self.areaView.center.y = self.view.frame.height / 2
  }

  @objc private func refreshAnnotations() {
    let numberOfAnnotations = Int(arc4random()) % 30 + 10
    let annotations = (0..<numberOfAnnotations).map { self.makeAnnotation(tag: $0) }
    self.mapView.removeAnnotations(self.mapView.annotations)
    self.mapView.addAnnotations(annotations)
    self.printVisibleAnnotations()
  }

  private func makeAnnotation(tag: Int) -> MKAnnotation {
    let annotation = MyAnnotation()
    annotation.tag = tag
    annotation.coordinate.latitude = self.random(
      self.mapView.region.center.latitude - self.mapView.region.span.latitudeDelta / 2,
      self.mapView.region.center.latitude + self.mapView.region.span.latitudeDelta / 2
    )
    annotation.coordinate.longitude = self.random(
      self.mapView.region.center.longitude - self.mapView.region.span.longitudeDelta / 2,
      self.mapView.region.center.longitude + self.mapView.region.span.longitudeDelta / 2
    )
    return annotation
  }

  private func random(_ min: CLLocationDegrees, _ max: CLLocationDegrees) -> CLLocationDegrees {
    return CLLocationDegrees(arc4random()).truncatingRemainder(dividingBy: max - min) + min
  }

  private func mapRect(from region: MKCoordinateRegion) -> MKMapRect {
    let topLeft = MKMapPointForCoordinate(CLLocationCoordinate2D(
      latitude: region.center.latitude + region.span.latitudeDelta / 2,
      longitude: region.center.longitude - region.span.longitudeDelta / 2
    ))
    let bottomRight = MKMapPointForCoordinate(CLLocationCoordinate2D(
      latitude: region.center.latitude - region.span.latitudeDelta / 2,
      longitude: region.center.longitude + region.span.longitudeDelta / 2
    ))
    let origin = MKMapPoint(x: topLeft.x, y: topLeft.y)
    let size = MKMapSize(
      width: abs(bottomRight.x - topLeft.x),
      height: abs(bottomRight.y - topLeft.y)
    )
    return MKMapRect(origin: origin, size: size)
  }

  private func printVisibleAnnotations() {
    let region = mapView.convert(self.areaView.frame, toRegionFrom: self.areaView.superview)
    let rect = self.mapRect(from: region)
    let annotations = mapView.annotations(in: rect).flatMap { $0 as? MyAnnotation }
    self.visibleAnnotationsItem.title = annotations.map { "\($0.tag)" }.joined(separator: ", ")
  }
}

extension ViewController: MKMapViewDelegate {
  func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
    if mapView.annotations.isEmpty {
      self.refreshAnnotations()
    }
  }

  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    self.printVisibleAnnotations()
  }

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let view = mapView.dequeueReusableAnnotationView(withIdentifier: "pin", for: annotation)
    if let annotation = annotation as? MyAnnotation {
      view.tag = annotation.tag
    }
    return view
  }
}

final class MyAnnotation: MKPointAnnotation {
  var tag: Int = 0
}

final class MyAnnotationView: MKPinAnnotationView {
  private let label: UILabel = {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 9)
    label.textColor = .white
    label.layer.shadowColor = UIColor.black.cgColor
    label.layer.shadowOpacity = 1
    label.layer.shadowRadius = 1 / UIScreen.main.scale
    label.layer.shadowOffset = .zero
    return label
  }()

  override var tag: Int {
    didSet {
      self.setNeedsLayout()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    self.label.text = "\(self.tag)"
    self.label.sizeToFit()
    self.label.center.x = self.frame.width / 2 / 2
    self.label.frame.origin.y = 1
    self.addSubview(self.label)
  }
}
