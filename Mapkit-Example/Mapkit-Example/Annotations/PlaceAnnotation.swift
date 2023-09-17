//
//  PlaceAnnotation.swift
//  Mapkit-Example
//
//  Created by 김태형 on 2023/09/18.
//

import Foundation
import MapKit

class PlaceAnnotation: MKPointAnnotation {
    
    let mapItem: MKMapItem  // 장소들을 접근할 수 있도록 해줌
    let id = UUID()
    var isSelected: Bool = false
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
        super.init()
        self.coordinate = mapItem.placemark.coordinate
    }
    
    // mapItem에 있는 장소 이름
    var name: String {
        mapItem.name ?? ""
    }
    
    // mapItem에 있는 전화번호
    var phone: String {
        mapItem.phoneNumber ?? ""
    }
    
    var address: String {
        "\(mapItem.placemark.subThoroughfare ?? "") \(mapItem.placemark.thoroughfare ?? "") \(mapItem.placemark.locality ?? "") \(mapItem.placemark.countryCode ?? "")"
    }
    
    // mapItem에 있는 장소
    var location: CLLocation {
        mapItem.placemark.location ?? CLLocation.default
    }
}
