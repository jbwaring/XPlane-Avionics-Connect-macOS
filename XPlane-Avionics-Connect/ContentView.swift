//
//  ContentView.swift
//  XPlane-Avionics-Connect
//
//  Created by Jean-Baptiste Waring on 2021-10-13.
//

import SwiftUI

struct ContentView: View {
    @State var engine1Rev = 0.0
    @State var engine2Rev = 0.0
    @State private var commandedThrottle = 50.0
    @State private var isEditingTrottle = false
    @State var errorMessagesOnScreen:[Int : AvionicErrorMessage ] = [1 : AvionicErrorMessage(color: Color(.yellow), message: "FLT CTRL NO DISPATCH")]
    var mySocket = XPlaneConnectMain.`init`(1);
    var body: some View {
        VStack{
            Image("caas_logo")
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .padding()
                .padding(.top)
        Text("XPlane Avionics Connect Demonstrator")
            .fontWeight(.bold)
            .padding()
        
                .padding()
            Button("Init Communication with XPlane", action: {
                DispatchQueue.main.async {
                    self.errorMessagesOnScreen[2] = AvionicErrorMessage(color: .red, message: "INIT COM XPLANE")
                    Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
                        onTickUpdateUIN1()
                        }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        self.errorMessagesOnScreen.removeValue(forKey: 1)
                        self.errorMessagesOnScreen.removeValue(forKey: 2)
                    })
                    }
                    
            })
            .padding()
            VStack {
                    Slider(
                        value: $commandedThrottle,
                        in: 0...100,
                        onEditingChanged: { editing in
                            isEditingTrottle = editing
                            DispatchQueue.main.async {
                                onEditSendThrottleCommand()
                            }
                        }
                    ).padding()
                    Text("Throttle \(commandedThrottle)")
                        .foregroundColor(isEditingTrottle ? .red : .blue)
            }.padding()
            ZStack{
                Rectangle()
                    .foregroundColor(.black)
                    
                
                    HStack{
                    ProgressView("Engine 1 N1", value: engine1Rev, total: 100)
                        .progressViewStyle(GaugeProgressStyle( quadrantName: "ENG 1\nN1"))
                        .frame(width: 200, height: 200)
                        .contentShape(Rectangle())
                        .padding()
                    
                    ProgressView("Engine 2 N1", value: engine2Rev, total: 100)
                        .progressViewStyle(GaugeProgressStyle( quadrantName: "ENG 2\nN1"))
                        .frame(width: 200, height: 200)
                        .contentShape(Rectangle())
                        .padding()
                        
                        VStack{
                            ForEach(errorMessagesOnScreen.keys.sorted(), id: \.self) { key in
                                Text("\(errorMessagesOnScreen[key]?.message ?? "")")
                                    .foregroundColor(errorMessagesOnScreen[key]?.color)
                                    .font(.custom("B612Mono-Regular", size: 12))
                                    .frame(width: 200)
                                    .padding(.vertical, 5)
                            }
                            
                        }
                    }.padding()
                    .animation(.easeInOut)
                    
                        
                
            

            }.padding()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
extension ContentView {
    
    func onTickUpdateUIN1() {
        let engine1 = mySocket?.getDataRefScalarFloat("sim/flightmodel/engine/ENGN_N1_", andSize: 8, andElement: 0) ?? 0.0
        let engine2 = mySocket?.getDataRefScalarFloat("sim/flightmodel/engine/ENGN_N1_", andSize: 8, andElement: 1) ?? 0.0
        DispatchQueue.main.async {
            self.engine1Rev = Double(engine1)
            self.engine2Rev = Double(engine2)
        }
    }
    func onEditSendThrottleCommand(){
        mySocket?.sendThrottleCommand(Float(commandedThrottle));
        
    }
    struct GaugeProgressStyle: ProgressViewStyle {
        var strokeColor = Color.green
        var strokeWidth = 10.0
        var quadrantName:String
        func makeBody(configuration: Configuration) -> some View {
            let fractionCompleted = configuration.fractionCompleted ?? 0
            let formatted = String(format: "%.1f %%", fractionCompleted*100)
            return ZStack {
                Circle()
                    .trim(from: 0, to: CGFloat(fractionCompleted))
                    .stroke(strokeColor, style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut)
                VStack{
                    Text("\(quadrantName)")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .font(.custom("B612Mono-Regular", size: 17))
                    .padding()
                    Text(formatted)
                    .multilineTextAlignment(.center)
                    .foregroundColor(fractionCompleted > 0.9 ? Color.red : Color.white)
                    .font(.custom("B612Mono-Italic", size: 20))
                    
                }
                    
            }
        }
    }
    
    struct AvionicErrorMessage {
    let id = UUID()
        let color:Color
        let message:String
    }
}
