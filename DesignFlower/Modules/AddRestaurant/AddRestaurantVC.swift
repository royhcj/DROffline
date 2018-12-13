//
//  AddRestaurantVC.swift
//  2017-dishrank-ios
//
//  Created by Roy Hu on 2018/10/2.
//

import UIKit
import RxSwift
import RxCocoa
import CountryAndCity

class AddRestaurantVC: UIViewController,
                       UIPickerViewDelegate,
                       UIPickerViewDataSource {
  
  // MARK: - ▷ View Model
  var vm: AddRestaurantVM?
  
  // MARK: - ▷ Rx
  var disposeBag = DisposeBag()
  
  var country = BehaviorRelay<CountryAndCity.Country?>(value: nil)
  var city    = BehaviorRelay<CountryAndCity.City?>(value: nil)
  
  var countryCandidates = BehaviorRelay<[CountryAndCity.Country]?>(value: nil)
  var cityCandidates    = BehaviorRelay<[CountryAndCity.City]?>(value: nil)
  
  // MARK: - ▷ Delegate
  weak var delegate: Delegate?
  
  // MARK: - ▷ Initializing Members
  var initialName: String?
  
  // MARK: - ▷ Country and City Models
  var countryInputView: UIPickerView?
  var cityInputView: UIPickerView?
  
  // MARK: - ▷ IBOutlets
  @IBOutlet var nameTextField: UITextField!
  @IBOutlet var countryLabel: UILabel!
  @IBOutlet var countryTextField: UITextField!
  @IBOutlet var cityLabel: UILabel!
  @IBOutlet var cityTextField: UITextField!
  @IBOutlet var addressTextField: UITextField!
  @IBOutlet var phoneTextField: UITextField!
  
  @IBOutlet var countryButton: UIButton!
  @IBOutlet var cityButton: UIButton!
  
  @IBOutlet var sendButton: UIButton!
  @IBOutlet var cancelButton: UIButton!
  
  // MARK: - ► Object lifecycle
  static func make(delegate: Delegate?, initialName: String?) -> AddRestaurantVC {
    let vc = UIStoryboard(name: "AddRestaurant", bundle: nil)
              .instantiateViewController(withIdentifier: "AddRestaurantVC")
              as! AddRestaurantVC
    vc.delegate = delegate
    vc.initialName = initialName
    vc.modalPresentationStyle = .overFullScreen
    return vc
  }
  
  // MARK: - ► View Model Manipulation
  func clearViewModel() {
    vm = nil
    disposeBag = DisposeBag()
  }
  
  func createViewModel() {
    clearViewModel()
    
    vm = AddRestaurantVM()
    if let vm = vm {
      bindViewModel(vm)
    }
  }
  
  func bindViewModel(_ vm: AddRestaurantVM) {
    let input = AddRestaurantVM.Input(
                    name: nameTextField.rx.text.asObservable(),
                 country: country.asObservable(),
                    city: city.asObservable(),
                 address: addressTextField.rx.text.asObservable(),
                   phone: phoneTextField.rx.text.asObservable(),
                    send: sendButton.rx.tap,
          fetchCountries: countryButton.rx.tap,
             fetchCities: cityButton.rx.tap.map { [unowned self] () in
                              self.country.value?.code
                            } )
    vm.bind(input: input)
    
    let output = vm.getOutput()
    
    output.country
      .map { $0?.name }
      .asDriver(onErrorJustReturn: nil)
      .drive(countryLabel.rx.text)
      .disposed(by: disposeBag)
    
    output.country.asObservable()
      .subscribe(onNext: { [unowned self] (_) in
        self.city.accept(nil)
      }).disposed(by: disposeBag)
    
    output.city
      .map { $0?.name }
      .asDriver(onErrorJustReturn: nil)
      .drive(cityLabel.rx.text)
      .disposed(by: disposeBag)

    output.sendResult
      .subscribe(onNext: { [unowned self] result in
        switch result {
          case .success(let info):
            self.delegate?.addRestaurantVC(sender: self,
                                 addedRestaurntWith: info)
            self.dismiss(animated: true, completion: nil)
          case .failure(let error):
            if case let .failedAddingRestaurant(_, message) = error {
              self.showAlert(title: nil, message: message, buttonTitle: "確認", buttonAction: nil)
            }
        }
      }).disposed(by: disposeBag)
    
    output.countryCandidates
      .asDriver(onErrorJustReturn: [])
      .drive(countryCandidates)
      .disposed(by: disposeBag)

    output.cityCandidates
      .asDriver(onErrorJustReturn: [])
      .drive(cityCandidates)
      .disposed(by: disposeBag)
    
    // Self binding
    cancelButton.rx.controlEvent(.touchUpInside)
      .subscribe { [weak self] _ in
        self?.dismiss(animated: true, completion: nil)
      }.disposed(by: disposeBag)
    
    countryCandidates.subscribe { countries in
        let inputView = self.getCountryInputView()
        inputView.reloadAllComponents()
      }.disposed(by: disposeBag)
    
    cityCandidates.subscribe { cities in
        let inputView = self.getCityInputView()
        inputView.reloadAllComponents()
      }.disposed(by: disposeBag)
    
    countryButton.rx
      .controlEvent(.touchUpInside)
      .subscribe(onNext: { () in
        self.countryTextField.becomeFirstResponder()
        
      }).disposed(by: disposeBag)
    
    cityButton.rx
      .controlEvent(.touchUpInside)
      .subscribe(onNext: { () in
        self.cityTextField.becomeFirstResponder()
      }).disposed(by: disposeBag)
    
    countryTextField.rx.controlEvent(.editingDidEnd)
      .subscribe(onNext: { [unowned self] (_) in
        if self.vm?.country.value == nil {
          self.country.accept(self.countryCandidates.value?.first)
        }
      }).disposed(by: disposeBag)
    
    cityTextField.rx.controlEvent(.editingDidEnd)
      .subscribe(onNext: { [unowned self] (_) in
        if self.vm?.city.value == nil {
          self.city.accept(self.cityCandidates.value?.first)
        }
      }).disposed(by: disposeBag)
  }
  
  // MARK: - ► View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    createViewModel()
    if let name = initialName {
      vm?.name.accept(name)
      nameTextField.rx.text.onNext(name)
    }
    
    countryTextField.inputView = getCountryInputView()
    cityTextField.inputView = getCityInputView()
  }
  
  // MARK: - ► Country and City Candidiates
  func getCountryInputView() -> UIPickerView {
    if let inputView = countryInputView {
      return inputView
    } else {
      let inputView = UIPickerView()
      inputView.delegate = self
      inputView.dataSource = self
      self.countryInputView = inputView
      return inputView
    }
  }
  
  func getCityInputView() -> UIPickerView {
    if let inputView = cityInputView {
      return inputView
    } else {
      let inputView = UIPickerView()
      inputView.delegate = self
      inputView.dataSource = self
      self.cityInputView = inputView
      return inputView
    }
  }
  
  // MARK: - ► PickerView DataSource/Delegate
  func pickerView(_ pickerView: UIPickerView,
                  titleForRow row: Int,
                  forComponent component: Int) -> String? {
    if pickerView === countryInputView,
       let country = countryCandidates.value?.at(row) {
      return country.name
    } else if pickerView === cityInputView,
      let city = cityCandidates.value?.at(row) {
      return city.name
    }
    return ""
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView,
                  numberOfRowsInComponent component: Int) -> Int {
    if pickerView === countryInputView {
      return countryCandidates.value?.count ?? 0
    } else if pickerView === cityInputView {
      return cityCandidates.value?.count ?? 0
    }
    return 0
  }
  
  func pickerView(_ pickerView: UIPickerView,
                  didSelectRow row: Int,
                  inComponent component: Int) {
    if pickerView === countryInputView,
       let country = countryCandidates.value?.at(row) {
      self.country.accept(country)
    } else if pickerView === cityInputView,
       let city = cityCandidates.value?.at(row) {
      self.city.accept(city)
    }
  }
  
}

protocol AddRestaurantVCDelegate: class {
  func addRestaurantVC(sender: AddRestaurantVC, addedRestaurntWith info: AddRestaurantVM.RestaurantInfo)
}
extension AddRestaurantVC {
  typealias Delegate = AddRestaurantVCDelegate
}

