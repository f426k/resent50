//
//  ContentView.swift
//  Resent50
//
//  Created by Fuka Takashima on 2023/07/20.
//

import SwiftUI
import CoreML
import Vision

struct ContentView: View {

    @State var classificationLabel = ""

    func createClassificationRequest() -> VNCoreMLRequest {
        do {
            let configuration = MLModelConfiguration()

            let model = try VNCoreMLModel(for: Resnet50(configuration: configuration).model)

            let request = VNCoreMLRequest(model: model, completionHandler: { request, error in
                performClassification(request: request)
            })

            return request

        } catch {
            fatalError("modelが読み込めません")
        }
    }

    // 画像分類の処理
    func performClassification(request:VNRequest){
        guard let results = request.results else {
            return
        }

        let classification = results as! [VNClassificationObservation]
        classificationLabel = classification[0].identifier
    }

    // 実際に画像を分類する
    func classifyImage(image:UIImage){
        // 入力された画像の型をUIImageからCIImageに変換
        guard let ciImage = CIImage(image:image) else {
            fatalError("CIImageに変換できません")
        }
        // handler作る
        let handler = VNImageRequestHandler(ciImage: ciImage)

        let classificationRequest = createClassificationRequest()

        do{
            try handler.perform([classificationRequest])
        }catch{
            fatalError("画像分類を失敗しました")
        }
    }

    var body: some View {
        VStack {
            Text(classificationLabel)
                .padding()
                .font(.title)

            Image("cat")
                .resizable()
                .frame(width: 300,height: 200)

            Button(action: {
                classifyImage(image: UIImage(named: "cat")!)
            }, label: {
                Text("この画像は何の画像？")
                    .padding()
            })
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
