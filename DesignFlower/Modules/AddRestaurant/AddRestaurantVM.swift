//
//  AddRestaurantVM.swift
//  2017-dishrank-ios
//
//  Created by Roy Hu on 2018/10/2.
//

import RxSwift
import RxCocoa
import Result
import CountryAndCity

class AddRestaurantVM {
  
  // MARK: - ❐ VM Input/Output
  struct Input {
    var name: Observable<String?>
    var country: Observable<Country?>
    var city: Observable<City?>
    var address: Observable<String?>
    var phone: Observable<String?>
    var send: ControlEvent<Void>
    var fetchCountries: ControlEvent<Void>
    var fetchCities: Observable<String?> // Country Code
  }
  
  struct Output {
    var name: Driver<String?>
    var country: Driver<Country?>
    var city: Driver<City?>
    var address: Driver<String?>
    var phone: Driver<String?>
    var sendResult: Observable<Result<RestaurantInfo, AddRestaurantError>>
    var countryCandidates: Observable<[Country]?>
    var cityCandidates: Observable<[City]?>
  }
  
  // MARK: - ❐ Models
  struct RestaurantInfo {
    var name: String
    var country: String?
    var city: String?
    var address: String?
    var phoneNumber: String?
  }
  
  enum AddRestaurantError: Error {
    case failedAddingRestaurant(name: String?, message: String)
  }
  
  typealias Country = CountryAndCity.Country
  typealias City = CountryAndCity.City
  
  // MARK: - ▷ VM Output
  var output: Output?
  
  // MARK: - ▷ Restaurant Infos
  var name = BehaviorRelay<String?>(value: nil)
  var country = BehaviorRelay<Country?>(value: nil)
  var city = BehaviorRelay<City?>(value: nil)
  var address = BehaviorRelay<String?>(value: nil)
  var phone = BehaviorRelay<String?>(value: nil)
  
  // MARK: - ▷ Country and Cities
  var countryCandidates = BehaviorRelay<[Country]?>(value: nil)
  var cityCandidates    = BehaviorRelay<[City]?>(value: nil)
  
  // MARK: - ▷ Action Results
  var sendResult = PublishSubject<Result<RestaurantInfo, AddRestaurantError>>()
  
  var disposeBag = DisposeBag()
  
  // MARK: - Object lifecyclde
  init() {
    if var language = Locale.preferredLanguages.first {
      print(language)
      if language.contains("zh-Hant") || language.contains("zh-TW") {
        language = "zh-Hant"
      } else if language.contains("en") {
        language = "en"
      }
      CountryCity.languageCode = language
    }
  }
  
  // MARK: - ► Bindings
  func bind(input: Input) {
    
    // Self bindings
    let fetchCity = PublishSubject<String?>()
    fetchCity
      .subscribe(onNext: { [weak self] countryCode in
        guard let countryCode = countryCode
        else {
            self?.cityCandidates.accept([])
            return
        }
        CountryCity.shared.fetchCities(for: countryCode,
                                       completion: { cities in
          self?.cityCandidates.accept(cities)
        })
      }).disposed(by: disposeBag)
    
    country
      .map { $0?.code }
      .asDriver(onErrorJustReturn: nil)
      .drive(fetchCity)
      .disposed(by: disposeBag)
    
    // Input bindings
    input.name
      .asDriver(onErrorJustReturn: nil)
      .drive(name)
      .disposed(by: disposeBag)
    
    input.country
      .asDriver(onErrorJustReturn: nil)
      .drive(country)
      .disposed(by: disposeBag)
    
    input.city
      .asDriver(onErrorJustReturn: nil)
      .drive(city)
      .disposed(by: disposeBag)
    
    input.address
      .asDriver(onErrorJustReturn: nil)
      .drive(address)
      .disposed(by: disposeBag)
    
    input.phone
      .asDriver(onErrorJustReturn: nil)
      .drive(phone)
      .disposed(by: disposeBag)
    
    input.send
      .subscribe { [weak self] _ in
        guard let name = self?.name.value else { return }
        
        let info = RestaurantInfo(name: name,
                                  country: self?.country.value?.name,
                                  city: self?.city.value?.name,
                                  address: self?.address.value,
                                  phoneNumber: self?.phone.value)
        self?.sendResult.onNext(.success(info))
        /* MARK OFF: 不需要createRestaurant API
        guard let accessToken = LoggedInUser.sharedInstance().accessToken,
              let shopName = self?.name.value
        else { return
        
        WebService.AddRating.createRestaurant(
            accessToken: accessToken,
            shopName:shopName)
          .then { [weak self] json -> Void in
            if json["statusCode"].int == 0,
               let id = json["shopID"].int,
               let name = self?.name.value {
              let info = RestaurantInfo(id: id, name: name)
              self?.sendResult.onNext(.success(info))
            } else {
              self?.sendResult.onNext(.failure(
                    .failedAddingRestaurant(name: self?.name.value,
                                            message: "新增失敗")))
            }
            
          }.catch { [weak self] error in
            print(error)
            self?.sendResult.onNext(.failure(
                      .failedAddingRestaurant(name: self?.name.value,
                                              message: "新增失敗")))
          }
        */
      }.disposed(by: disposeBag)
    
    input.fetchCountries
      .subscribe(onNext: { [weak self] () in
        CountryCity.shared.fetchCountries(completion: { countries in
          self?.countryCandidates.accept(countries)
        })
      }).disposed(by: disposeBag)

    input.fetchCities
      .asDriver(onErrorJustReturn: nil)
      .drive(fetchCity)
      .disposed(by: disposeBag)
  }
  
  func getOutput() -> Output {
    if output == nil {
      output = Output(name: name.asDriver(onErrorJustReturn: nil),
                   country: country.asDriver(onErrorJustReturn: nil),
                      city: city.asDriver(onErrorJustReturn: nil),
                   address: address.asDriver(onErrorJustReturn: nil),
                     phone: phone.asDriver(onErrorJustReturn: nil),
                sendResult: sendResult,
         countryCandidates: countryCandidates.asObservable(),
            cityCandidates: cityCandidates.asObservable())
    }
    return output!
  }
  
  
  
}
