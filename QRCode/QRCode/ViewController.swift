//
//  ViewController.swift
//  QRCode
//
//  Created by Hank on 2016/9/22.
//  Copyright © 2016年 Hank. All rights reserved.
//

//Import 多媒體相關的class function
import UIKit
import AVFoundation

//使其class繼承遵循AVCaptureMetadataOutputObjectsDelegate
class ViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {

    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var result: UILabel!
    
    var objCaptureSession:AVCaptureSession?
    var objCaptureVideoPreviewLayer:AVCaptureVideoPreviewLayer?
    var vwQRCode:UIView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //呼叫下列三個function
        self.configureVideoCapture()
        self.addVideoPreviewLayer()
        self.initializeQRView()
    }
    
    //定義資料抓取結構以及資料型態
    func configureVideoCapture() {
        
        //呼叫AVCaptureDevice這個class，他會回傳一個現有可利用的devices的array，之後我們可以呼叫
        //defaultDeviceWithMediaType這個func選擇default媒體資料輸入來源．這邊將其設定為視訊媒體．
        let objCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        //定義Error Type
        var error:NSError?
        //定義抓取資料輸入型態
        let objCaptureDeviceInput: AnyObject!
        
        do {
            //將輸入原指定為稍早設定的objCaptureDevice，as a defaultl data Input
            objCaptureDeviceInput = try AVCaptureDeviceInput(device: objCaptureDevice) as AVCaptureDeviceInput
            
            //catch error from do method
        } catch let error1 as NSError {
            error = error1
            objCaptureDeviceInput = nil
        }
        //若遇到有error 的狀態，利用UIAlertView這個function通知使用者．
        if (error != nil) {
            //實體化一個alertView，並將其內容文字定義進去．
            let alertView:UIAlertView = UIAlertView(title: "Device Error", message:"Device not Supported for this Application", delegate: nil, cancelButtonTitle: "Ok Done")
            
            //將此警示訊息show出來
            alertView.show()
            return
        }
        
        //AVCaptureSession類似作為一個訊息轉換器，可以定義(輸入)/(輸出)的資料，並且作為中介者．
        objCaptureSession = AVCaptureSession()
        objCaptureSession?.addInput(objCaptureDeviceInput as! AVCaptureInput)
        let objCaptureMetadataOutput = AVCaptureMetadataOutput()
        objCaptureSession?.addOutput(objCaptureMetadataOutput)
        objCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        objCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
    }
    
    
    //此func將Creates an AVCaptureVideoPreviewLayer for previewing the visual output of the
    //specified AVCaptureSession.
    func addVideoPreviewLayer()
    {
        //定義video preview layer的型態並指定輸入資料來源以及輸出型態．(session)
        objCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: objCaptureSession)
        //定義preview畫面如何呈現
        objCaptureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        //定義preview畫面的aspect框
        objCaptureVideoPreviewLayer?.frame = view.layer.bounds
        self.view.layer.addSublayer(objCaptureVideoPreviewLayer!)
        objCaptureSession?.startRunning()
        
        //將subview帶出來
        self.view.bringSubviewToFront(label)
        self.view.bringSubviewToFront(result)
        
    }
    
    
    //帶出QRcode小view在最上層
    //
    //怎麼知道何時會跳出來？？？判斷機制為何？？？
    //-> 請看下方的captureOutput裡面的判斷式子
    func initializeQRView() {
        vwQRCode = UIView()
        vwQRCode?.layer.borderColor = UIColor.redColor().CGColor
        vwQRCode?.layer.borderWidth = 5
        //定義這個view為option!是因為他有可能不存在
        self.view.addSubview(vwQRCode!)
        self.view.bringSubviewToFront(vwQRCode!)
    }
    
    
    
    
    // MARK :  delegate
    
    //AVCaptureOutput 定義了由session傳輸來的資料終點．
    //metadataObjects -> 資料型態為AnyObject 
    //AVCaptureConnection -> capture in/ out的橋樑
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        //此地方就是判斷QRCode辨識到時的小框框要不要顯示出來的地方．
        if metadataObjects == nil || metadataObjects.count == 0 {
            vwQRCode?.frame = CGRectZero
            result.text = "NO QRCode text detacted"
            return
        }
        
        //將output data物件實體化，並且利用AVMetadataMachineReadableCodeObject定義其邊界範圍，並且判斷是否為可讀Metadata
        let objMetadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        //定義想辨認物件的型態為QRCode，若符合就進入 if{裡面}
        if objMetadataMachineReadableCodeObject.type == AVMetadataObjectTypeQRCode {
            
            //將影像物件的圖像邊界轉成layer這邊的影像圖邊界
            let objBarCode = objCaptureVideoPreviewLayer?.transformedMetadataObjectForMetadataObject(objMetadataMachineReadableCodeObject as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            
            //之後將QRcode的 frame指定為上述得影像邊界
            vwQRCode?.frame = objBarCode.bounds;
            
            //將QR Code所帶的String value顯示出來．
            if objMetadataMachineReadableCodeObject.stringValue != nil {
                result.text = objMetadataMachineReadableCodeObject.stringValue
            }
            
        }
        
    }

   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

