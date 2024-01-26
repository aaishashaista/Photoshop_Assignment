//
//  ViewController.swift
//  HomePageDemo
//
//  Created by Aaisha Sanglikar on 22/01/24.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var onTapTakePhotoBtn: UIButton!
    var documentInteractionController : UIDocumentInteractionController!
    let context = CIContext()
    var image : UIImage!
    var originalCIImage : CIImage!
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func onTapSave(_ sender: Any) {
        if let image = imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @IBAction func onTapTakePhoto(_ sender: Any) {
        self.btnFilter.isHidden = false
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self;
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func onTapShare(_ sender: Any) {
        let urlWhats = "whatsapp://app"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed) {
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                    if let image = UIImage(named: "whatsappIcon") {
                        if let imageData = image.jpegData(compressionQuality: 1.0) {
                            let tempFile = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/whatsAppTmp.wai")
                            do {
                                try imageData.write(to: tempFile, options: .atomic)
                                self.documentInteractionController = UIDocumentInteractionController(url: tempFile)
                                self.documentInteractionController.uti = "net.whatsapp.image"
                                self.documentInteractionController.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
                            } catch {
                                print(error)
                            }
                        }
                    }
                } else {
                    print("Cannot open whatsapp")
                }
            }
        }
    }
    @IBAction func onTapShowText(_ sender: Any) {
        imageView.image = addTextToImage(imageView.image!, text:"Hello Swift!")
    }
    
    @IBAction func onTapFilter(_ sender: Any) {
        originalCIImage = CIImage(image: imageView.image!)
        if let filteredImage = applyFilter(to: imageView.image!) {
            imageView.image = filteredImage
        }
    }
    
    func generateImageWithText(text: String) -> UIImage? {
        let image = imageView.image!
        
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = UIColor.clear
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        label.textColor = UIColor.red
        label.text = text
        
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let imageWithText = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return imageWithText
    }
    
    private func store_image_on_phone(image: UIImage, image_name: String) -> URL? {
        
        let imagePath: String = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(image_name).png"
        let imageUrl: URL = URL(fileURLWithPath: imagePath)
        
        // Store
        do {
            try image.pngData()?.write(to: imageUrl)
            return imageUrl
        } catch {
            return nil
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // Handle the error
            print("Error saving image: \(error.localizedDescription)")
        } else {
            // Image saved successfully
            print("Image saved successfully")
        }
    }
    
}

extension ViewController {
    func applyFilter(to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(8.0, forKey: kCIInputRadiusKey) // Set the filter parameter
        
        guard let outputCIImage = filter?.outputImage else { return nil }
        
        let context = CIContext(options: nil)
        guard let filteredCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
        
        let filteredImage = UIImage(cgImage: filteredCGImage)
        
        return filteredImage
    }
}

extension ViewController {
    func addTextToImage(_ image: UIImage, text: String) -> UIImage {
        let font = UIFont.systemFont(ofSize: 120)
        let textColor = UIColor.white
        let textFontAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: textColor,
        ]
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let textSize = text.size(withAttributes: textFontAttributes)
        let textX = (image.size.width - textSize.width) / 2
        let textY = (image.size.height - textSize.height) / 2
        
        text.draw(at: CGPoint(x: textX, y: textY), withAttributes: textFontAttributes)
        
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return image
        }
        
        return newImage
    }
}
