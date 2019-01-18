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
    }


}



