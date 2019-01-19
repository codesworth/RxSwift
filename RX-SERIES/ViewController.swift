//
//  ViewController.swift
//  RX-SERIES
//
//  Created by Mensah Shadrach on 17/01/2019.
//  Copyright © 2019 Mensah Shadrach. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    public func example(of description: String, action: () -> Void) {
        print("\n--- Example of:", description, "---")
        action()
        
    }
    

//    let observable: Observable<Int>  = Observable<Int>.just(one)
//
//    let observable2 = Observable.of(one, two, three)
//
//    let observable4 = Observable.from([one,two])
//
//    let sequence = 0..<3
//
//    var iterator = sequence.makeIterator()
//    while let n = iterator.next(){
//        print(n)
//    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func viewDidAppear(_ animated: Bool){
        
        example(of: "subscribe") {
            let one  = 1
            let two = 2
            let three = 3
            
            let observable = Observable.of(one,two,three)
            
            let _ = observable.subscribe(onNext: { (e) in
                print(e)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            
        }
        
        example(of: "ranges"){
            let observable = Observable<UInt>.range(start: 0, count: 10)
            
            
            
            let _ = observable.subscribe(onNext: { (val) in
                let n = Double(val)
                let fib = Int(((pow(1.61803, n) - pow(0.61803, n)) / 2.23606).rounded())
                print("fib for: \(n) is \(fib)")
            }, onError: { (err) in
                print("Error occurred: \(err.localizedDescription)")
            }, onCompleted: {
                print("DId Complete")
            }, onDisposed: {
                print("Was Disposed")
            })

        }
        
        example(of: "Fasctorie") {
            let disposebag = DisposeBag()
            var flip = false
            
            
            let fsctory = Observable<UInt>.deferred({ () -> Observable<UInt> in
                
                flip = !flip
                if flip{
                    return Observable.of(1,3,5)
                }else{
                    return Observable.of(4,6,7)
                }
            })
            
            for _ in 0...3{
                fsctory.subscribe(onNext: {
                    print($0, terminator: "")
                }).disposed(by: disposebag)
                print()
            }
        }
        
        example(of: "Single Trait") {
            let disposeBag = DisposeBag()
            
            enum FileReadError:Error {
                case fileNotFound
                case unreadable
                case encodingFailed
            }
            
            func loadText(from name:String) -> Single<String>{
                return Single.create{ single in
                    let disposable = Disposables.create()
                    guard let path = Bundle.main.path(forResource: name, ofType: ".txt") else{
                        single(.error(FileReadError.fileNotFound))
                        return disposable
                    }
                    
                    guard let data = FileManager.default.contents(atPath: path) else{
                        single(.error(FileReadError.unreadable))
                        return disposable
                    }
                    
                    guard let contents = String(data: data, encoding: .utf8) else{
                        single(.error(FileReadError.encodingFailed))
                        return disposable
                    }
                    
                    single(.success(contents))
                    return disposable
                    
                }
            }
            
            loadText(from: "Lorms").subscribe{
                switch $0{
                case .success(let content):
                    print(content)
                    break
                case .error(let err):
                    print(err)
                    break
                }
            }.disposed(by: disposeBag)
        }
        
        
        
        example(of: "never") {
            let bag = DisposeBag()
            let observable = Observable.just(3)
            let d = observable.do(onNext: { (x) in
                print(x)
            }, onError: { (err) in
                print(err.localizedDescription)
            }, onCompleted: {
                print("Completed")
            }, onSubscribe: {
                print("Will Subscribe")
            }, onSubscribed: {
                print("Did Subscribe")
            }, onDispose: {
                print("will be disposed")
            }).subscribe().disposed(by: bag)
            
            example(of: "Subject", action: {
                let subject = PublishSubject<String>()
                subject.onNext("Anybody out there")
                
                let subscription1 = subject.subscribe(onNext: { (str) in
                    print(str)
                })
                
                subject.on(.next("Hello Boy"))
            })
            
            
            example(of: "BehaviourSubject", action: {
                let subject = BehaviorSubject(value: "Initial Value")
                let bag = DisposeBag()
                subject.onNext("Heyaa")
                subject.subscribe{
                    self.iprint(label: "1", event: $0)
                }.disposed(by: bag)
            })
            
        }
        
        example(of: "ReplaySubject") {
            let subject = ReplaySubject<String>.create(bufferSize: 2)
            let bag = DisposeBag()
            subject.onNext("1")
            subject.onNext("2")
            subject.onNext("3")

            subject.subscribe{
                self.iprint(label: "1", event: $0)
            }.disposed(by: bag)
            
            subject.subscribe{
                self.iprint(label: "2", event: $0)
            }.disposed(by: bag)
        }
        
        example(of: "Variable") {
            let variable = Variable("Inotial value")
            let bag = DisposeBag()
            variable.value = "New Value"
            
            variable.asObservable().subscribe{
                self.iprint(label: "1", event: $0)
            }.disposed(by: bag)
        }
    }

    enum MyError:Error {
        case anError
    }
    
    func iprint<T:CustomStringConvertible>(label:String,event:Event<T>){
        print(label, event.element ?? (event.error ?? event) ?? event)
    }

}



