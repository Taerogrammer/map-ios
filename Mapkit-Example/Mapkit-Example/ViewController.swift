//
//  ViewController.swift
//  Mapkit-Example
//
//  Created by 김태형 on 2023/09/17.
//


import UIKit
import MapKit   // 지도 관련 프레임워크
import CoreLocation     // 위치 관련 프레임워크

/**
 https://www.youtube.com/watch?v=LqQKHjHqaeM : 42분까지 완료함 !!
 */
class ViewController: UIViewController {

    var locationManager: CLLocationManager?
    
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        map.translatesAutoresizingMaskIntoConstraints = false
        
        return map
    }()
    
    lazy var searchTextField: UITextField = {
        let searchTextField = UITextField()
        searchTextField.layer.cornerRadius = 10
        searchTextField.delegate = self
        searchTextField.clipsToBounds = true
        searchTextField.backgroundColor = .white
        searchTextField.placeholder = "Search"
        searchTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))  // placeholder 글씨가 왼쪽에서 약간 띄워져있도록
        searchTextField.leftViewMode = .always
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        return searchTextField
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        setupUI()
        
    }

    

    
}

extension ViewController {
    
    private func setupUI() {
        view.addSubview(searchTextField)
        view.addSubview(mapView)
        view.bringSubviewToFront(searchTextField)   // searchTextField를 뷰의 상단에 위치시킴
        
        searchTextField.returnKeyType = .go

        // constraints를 정해주어야 화면에 로딩
        NSLayoutConstraint.activate([
            searchTextField.heightAnchor.constraint(equalToConstant: 44),
            searchTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchTextField.widthAnchor.constraint(equalToConstant: view.bounds.size.width/1.2),
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),

            mapView.widthAnchor.constraint(equalTo: view.widthAnchor),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor),
            mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        
        locationManager?.requestWhenInUseAuthorization()
        
//        locationManager?.requestAlwaysAuthorization() --> 이것을 사용하려면 info.plist에서 Privacy - Location Always and When In Use Usage Description 추가해야 함
        
        locationManager?.requestLocation()
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager, let location = locationManager.location else { return }
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // location.coordinate를 기반으로 하여 region을 생성하고, 해당 region을 지도(mapView)에 띄움
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 750, longitudinalMeters: 750)   // zoom이 되는 미터 반경 설정
            mapView.setRegion(region, animated: true)
        case .denied:
            print("Location services has been denied.")
        case .notDetermined, .restricted:
            print("Location cannot be determined or restricted.")
        @unknown default:
            print("Unknown error.")
        }
    }

}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()    // 사용자가 위치 공유를 허용했는지 확인
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let text = textField.text ?? ""
        if !text.isEmpty {
            textField.resignFirstResponder()
            
            // 근처 장소 찾기
            findNearbyPlaces(by: text)
        }
        
        return true
    }
    
    // 탐색한 단어를 기준으로 근처에 있는 장소 찾아주는 메서드
    private func findNearbyPlaces(by query: String) {
        
        // 어노테이션 전체 제거
        mapView.removeAnnotations(mapView.annotations)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let response = response, error == nil else { return }
            
            let places = response.mapItems.map(PlaceAnnotation.init)    // 검색한 장소들
            places.forEach { place in
                self?.mapView.addAnnotation(place)
            }
            
            
            print(response.mapItems)
        }
        
    }
}
