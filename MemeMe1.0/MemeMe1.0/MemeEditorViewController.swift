//
//  ViewController.swift
//  MemeMe1.0
//
//  Created by Jimin Kim on 11/11/20.
//  Copyright © 2020 Jimin Kim. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var topToolBar: UIToolbar!
    
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -6.0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupTextField(tf: topTextField, text: "TOP")
        setupTextField(tf: bottomTextField, text: "BOTTOM")
        
        shareButton.isEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func setupTextField(tf: UITextField, text: String) {
     // setup attributes of the textfield here
        tf.textAlignment = .center
        tf.defaultTextAttributes = memeTextAttributes
        tf.text = text
        tf.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }

    @IBAction func pickAnImage(_ sender: Any) {
        
        chooseImageFromCameraOrPhoto(source: .photoLibrary)
        
    }
    
    @IBAction func takeAPicture(_ sender: Any) {
        
        chooseImageFromCameraOrPhoto(source: .camera)
        
    }
    
    func chooseImageFromCameraOrPhoto(source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imagePickerView.image = image
        shareButton.isEnabled = true
        dismiss(animated: true, completion: nil)
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {

        if bottomTextField.isEditing {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {

        if bottomTextField.isEditing {
            view.frame.origin.y = 0
        }
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    @IBAction func shareTabbed(_ sender: Any) {
        let image = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.isModalInPresentation = true
        controller.completionWithItemsHandler = { (_, completed, _, _) in
            if completed {
                self.save()
            }
        }
        present(controller, animated: true, completion: nil)
    }
    
    func save() {
            // Create the meme
            let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
    }
    
    func generateMemedImage() -> UIImage {
        
        topToolBar.isHidden = true
        bottomToolBar.isHidden = true

        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        topToolBar.isHidden = false
        bottomToolBar.isHidden = false

        return memedImage
    }
    
    
    @IBAction func cancelTabbed(_ sender: Any) {
        
        setupTextField(tf: topTextField, text: "TOP")
        setupTextField(tf: bottomTextField, text: "BOTTOM")
        
        shareButton.isEnabled = false
        
        imagePickerView.image = nil
        
        
    }
    
    
}


