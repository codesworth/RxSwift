/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import RxSwift

class MainViewController: UIViewController {

  @IBOutlet weak var imagePreview: UIImageView!
  @IBOutlet weak var buttonClear: UIButton!
  @IBOutlet weak var buttonSave: UIButton!
  @IBOutlet weak var itemAdd: UIBarButtonItem!

    private let bag = DisposeBag()
    private let images = Variable<[UIImage]>([])
  override func viewDidLoad() {
    super.viewDidLoad()
    images.asObservable().subscribe(onNext:{ [weak self] photos in
        guard let preview = self?.imagePreview else {return}
        preview.image = UIImage.collage(images: photos, size: preview.frame.size)
        self?.updateUI(photos: photos)
    }).disposed(by: bag)
    
  }
    
    func updateUI(photos:[UIImage]){
       buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
       buttonClear.isEnabled = photos.count > 0
        itemAdd.isEnabled = photos.count < 6
        title = photos.count > 0 ? "\(photos.count) Photos" : "Collage"
    }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  @IBAction func actionClear() {
    images.value = []
  }

  @IBAction func actionSave() {
    guard let image = imagePreview.image else {return}
    
    PhotoWriter.save(image).subscribe(onSuccess: { [weak self](id) in
        self?.showMessage("Saved with id: \(id)")
        self?.actionClear()
    }) { (err) in
        self.showMessage("Error", description: err.localizedDescription)
    }.disposed(by: bag)
  }

  @IBAction func actionAdd() {
    //images.value.append(UIImage(named: "IMG_1907.jpg")!)
    let photosController = storyboard!.instantiateViewController(withIdentifier: String(describing: PhotosViewController.self)) as! PhotosViewController
    photosController.selectedPhotos.subscribe(onNext: { [weak self] image in
        guard let images = self?.images else{return}
        images.value.append(image)
        }, onError: { (err) in
            print(err)
    }) {
        print("Completed Photo Selection")
    }.disposed(by: bag)
    navigationController?.pushViewController(photosController, animated: true)
  }

  func showMessage(_ title: String, description: String? = nil) {
    let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak self] _ in self?.dismiss(animated: true, completion: nil)}))
    present(alert, animated: true, completion: nil)
  }
}
