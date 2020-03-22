//
//  ViewController.swift
//  MailApp
//
//  Created by hitoshi on 2020/03/20.
//  Copyright © 2020 Toshi. All rights reserved.
//

import UIKit
import MessageUI

class ViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var quoteFileLabel: UILabel!
    @IBOutlet weak var mailContentPlaceholder: UILabel!
    @IBOutlet weak var mailContet: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toTextBox: UITextField!
    @IBOutlet weak var subjectTextBox: UITextField!
    @IBOutlet weak var messageTextBox: UITextView!
    var imagePicker: UIImagePickerController!;
    var attachedImage: UIImage!;
//    var mailComponentVC: MFMailComposeViewController!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //textViewに関するdelegateをこのクラスに記述する
        mailContet.delegate = self;
        quoteFileLabel.text = "";
        
        //カメラロールを呼び出すためのクラス、delegateを追加
        self.imagePicker = UIImagePickerController();
        self.imagePicker.delegate = self;
        
        //キーボードに関するdelegate
        self.toTextBox.delegate = self;
        self.subjectTextBox.delegate = self;
        self.messageTextBox.delegate = self;
        
        self.attachedImage = UIImage();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //キーボードを閉じる
        self.toTextBox.resignFirstResponder();
        self.subjectTextBox.resignFirstResponder();
        self.messageTextBox.resignFirstResponder();
        return true;
    }
    
    @IBAction func sendMail(_ sender: Any) {
        
        //To
        guard let to = self.toTextBox.text else {
            return;
        }
        
        let toArray = to.components(separatedBy: ",");
        
        //Toにアドレスが入力されているか確認
        for to in toArray {
            if(to.isEmpty) {
                showAlert(title: "Error", message: "Enter mail address!");
                return;
            }
        }
        
        //Subject
        guard let subject = self.subjectTextBox.text else {
            return;
        }
        
        //Message
        guard let message = self.messageTextBox.text else {
            return;
        }
        
        if (subject.isEmpty) {
            showAlert(title: "Confirm", message: "No subject. Please enter it.");
            return;
        }
        
    
        let mailController = self.configMailController(
                            toArray: toArray, subject: subject,
                            message: message, attachedImage: self.attachedImage);
        
        mailController.mailComposeDelegate = self;
        
        if(MFMailComposeViewController.canSendMail()) {
            
            
//            UINavigationBar.appearance().barTintColor = .mv_primary
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            if #available(iOS 13.0, *) {
                UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            }
            //メール送信
            mailController.navigationBar.backgroundColor = UIColor.white;
            mailController.navigationBar.showsLargeContentViewer = true;
            
            present(mailController, animated: true);
            
        } else {
            //alert通知
            showAlert(title: "Error", message: "Could not send mail.");
        }
    }
    
    func configMailController(toArray: [String], subject: String, message: String, attachedImage: UIImage) -> MFMailComposeViewController {
        
        let mailComponentVC = MFMailComposeViewController();
        //送り先(To)を設定
        mailComponentVC.setToRecipients(toArray);
        
        //件名を設定
        mailComponentVC.setSubject(subject);
        
        //メッセージ本文を設定
        mailComponentVC.setMessageBody(message, isHTML: false);
        
        if (attachedImage != nil) {
            let img = attachedImage.jpegData(compressionQuality: 1.0);
            //画像があれば追加する
            mailComponentVC.addAttachmentData(img!, mimeType: "image/png", fileName: "image")
            
        }
        return mailComponentVC;
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
            case .cancelled:
                print("Send email has been cancelled.")
                break;
            
            case .saved:
                print("Saved email draft.");
                break;
            
            case .sent:
                print("Email has been sent.");
                break;
            
            case .failed:
                print("Send email has failed.");
                break;
            
            default:
                break;
        }
        //モーダルを閉じる
        controller.dismiss(animated: true, completion: nil);
        
    }
    
    //MailAddress確認
    func hasMailAddress() -> Bool {
        
        guard let to = self.toTextBox.text else {
            //nil
            return false;
        }
        
        if(to.isEmpty){
            showAlert(title: "Error", message: "Enter mail address!");
            return false;
        }
        
        return true;
    }
    
    //Subject確認
    func hasSubject() -> Bool {
        
        guard let subject = self.subjectTextBox.text else {
            //nil
            return false;
        }
        
        if(subject.isEmpty){
            
            showAlert(title: "Caution!",
                      message: "Subject is not input. Is that ok to send it?");
            
            return false;
        }
        return true;
    }
    
    //textViewがフォーカスされたらLabelをい非表示
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        //Place holderを隠す
        self.mailContentPlaceholder.isHidden = true;
        return true;
    }
    
    //textViewの編集が終わった時に呼ばれるイベント
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if(self.mailContet.text.isEmpty) {
            //編集後mailContentが空の場合、placeholderを表示。
            self.mailContentPlaceholder.isHidden = false;
        }
        
        return true;
    }
    //textViewの編集が終わった時に呼ばれるイベント
//    func textViewDidEndEditing(_ textField: UITextField) {
//        if(self.mailContet.text.isEmpty) {
//            //編集後mailContentが空の場合、placeholderを表示。
//            self.mailContentPlaceholder.isHidden = false;
//        }
    
        //こちらは呼ばれなかったがその理由は？
//    }

    
    @IBAction func accessToCameraRoll(_ sender: Any) {

        //カメラロールの呼び出し
        present(self.imagePicker, animated: true);
    }
    
    //[TODO] UIImageをリサイズする処理を完成させること
    func getResizedImage(ratio: CGFloat, image: UIImage) -> UIImage {
        
//        let aspectScale = image.size.height / image.size.width;
        let scale: CGFloat = 2;

        let resizedSize = CGSize(width: CGFloat(image.size.width) / scale,
                                 height: CGFloat(image.size.height) / scale);

        //リサイズ後のUIImageを生成する
        UIGraphicsBeginImageContext(resizedSize);
        image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height));

        let resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return resizedImage!;
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("image is nil");
            return;
        }
          
        //取得した画像をimageViewに登録
//        let rect = CGRect(x: 0, y: 0, width: self.imageView.bounds.width, height: self.imageView.bounds.height);
        
        //画像の縦横サイズを保ったままimageViewにえ全体が収まるように画像を入れる
        self.imageView.contentMode = .scaleAspectFit;
        
//        self.imageView.frame = rect;
        
        //imageViewに貼り付ける
        self.imageView.image = image;
        
        //attachedImageにコピー
        self.attachedImage = image;
        
        //
//        let fullString = NSMutableAttributedString(string: self.messageTextBox.text);
//
//        let imageAttachment = NSTextAttachment();
//
//        //カメラロールで取得し縮小したimageを代入
//        imageAttachment.image = image;
//
//        let imageString = NSAttributedString(attachment: imageAttachment);
//        fullString.append(imageString);
//
//
//        //textViewに画像を含んだテキストをセット
//        self.messageTextBox.attributedText = fullString;
        
        //カメラロールを閉じる--->書かないと自動で閉じてくれない
        self.imagePicker.dismiss(animated: true, completion: nil);
     
    }
    
    //Alertを表示する
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        
        let defaultAction = UIAlertAction(title: "OK",
            style: .default, handler: nil);
        
        alert.addAction(defaultAction);
        
        self.present(alert, animated: true, completion: nil);
    }
}

