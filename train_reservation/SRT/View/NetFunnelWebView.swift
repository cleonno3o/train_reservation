//
//  NetFunnelWebView.swift
//  train_reservation
//
//  Created by sumin on 8/3/25.
//

import SwiftUI
import WebKit

// 넷퍼넬 처리를 위한 WKWebView 래퍼 View
struct NetFunnelWebView: UIViewRepresentable {
    let url: URL // 넷퍼넬 페이지의 URL을 외부에서 주입받습니다. (예: https://nf.letskorail.com/ts.wseq)
    var onCompletion: (String?) -> Void // 넷퍼넬 키를 추출하거나 실패했을 때 호출될 클로저입니다. String? 타입으로 키를 반환합니다.

    // MARK: - UIViewRepresentable 필수 메서드

    // WKWebView 인스턴스를 생성하고 초기 설정을 합니다.
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView() // 새로운 WKWebView 객체를 생성합니다.
        // 웹뷰의 내비게이션 이벤트를 처리할 델리게이트를 설정합니다.
        // context.coordinator는 아래 makeCoordinator()에서 생성된 Coordinator 인스턴스입니다.
        webView.navigationDelegate = context.coordinator
        return webView // 생성된 웹뷰를 반환합니다.
    }

    // View의 상태가 업데이트될 때 WKWebView를 업데이트합니다.
    // 여기서는 URL이 변경될 경우를 대비하여 요청을 다시 로드합니다. (이 경우는 거의 없음)
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url) // 주입받은 URL로 URLRequest를 생성합니다.
        uiView.load(request) // 웹뷰에 해당 요청을 로드하여 페이지를 띄웁니다.
    }

    // WKWebView의 델리게이트 역할을 할 Coordinator 객체를 생성합니다.
    func makeCoordinator() -> Coordinator {
        Coordinator(self) // 현재 NetFunnelWebView 인스턴스를 Coordinator에 전달하여 부모 View에 접근할 수 있게 합니다.
    }

    // MARK: - Coordinator 클래스 (WKWebViewDelegate 역할)

    // WKWebView의 내비게이션 이벤트를 처리하는 델리게이트 클래스입니다.
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: NetFunnelWebView // 부모 NetFunnelWebView 인스턴스에 대한 참조입니다.

        init(_ parent: NetFunnelWebView) {
            self.parent = parent
        }

        // 웹뷰 로딩이 완료되었을 때 호출되는 델리게이트 메서드입니다.
        // 넷퍼넬 키를 추출하는 JavaScript를 실행하는 핵심 로직이 여기에 있습니다.
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // srt.py의 _parse 함수에서 'NetFunnel.gControl.result' 변수를 찾는 것을 참고했습니다.
            // 이 JavaScript 변수는 넷퍼넬 처리 결과(키 포함)를 담고 있을 것으로 예상됩니다.
            let javascript = "NetFunnel.gControl.result" 
            // 웹뷰 내에서 JavaScript 코드를 실행하고 결과를 비동기적으로 받습니다.
            webView.evaluateJavaScript(javascript) { result, error in
                // JavaScript 실행 결과가 String 타입인지 확인합니다.
                if let resultString = result as? String {
                    // srt.py의 파싱 로직을 Swift로 재현합니다.
                    // 응답 문자열은 'code:status:params_str' 형태일 것으로 예상됩니다.
                    let components = resultString.split(separator: ":", maxSplits: 2)
                    // 컴포넌트가 3개(code, status, params_str)인지 확인합니다.
                    if components.count == 3 {
                        let paramsStr = String(components[2]) 
                        // params_str에서 'key=값' 형태를 정규식으로 찾아 '값' (넷퍼넬 키)을 추출합니다.
                        // 정규식: "key=([^&]+)" -> 'key=' 뒤에 '&'가 나오기 전까지의 모든 문자열을 캡처합니다.
                        if let keyMatch = paramsStr.range(of: "key=([^&]+)", options: .regularExpression) {
                            // 추출된 문자열에서 'key=' 부분을 제거하고 순수한 넷퍼넬 키만 남깁니다.
                            let netfunnelKey = String(paramsStr[keyMatch].dropFirst("key=".count))
                            // 추출된 넷퍼넬 키를 onCompletion 클로저를 통해 부모 View로 전달합니다.
                            self.parent.onCompletion(netfunnelKey)
                            return // 키를 찾았으므로 함수를 종료합니다.
                        }
                    }
                }
                // 키를 찾지 못했거나 JavaScript 실행 중 오류가 발생한 경우 nil을 반환합니다.
                self.parent.onCompletion(nil)
            }
        }

        // 웹뷰가 새로운 URL로 이동하려고 할 때 호출되는 델리게이트 메서드입니다.
        // 여기서 모든 네트워크 요청을 감시하고 출력할 수 있습니다.
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            // --- [디버깅 코드 시작] ---
            // Chrome 개발자 도구의 네트워크 탭처럼 요청 정보를 출력합니다.
            if let url = navigationAction.request.url {
                print("==================================================")
                print("[WebView Request] URL: \(url.absoluteString)")
            }
            
            if let method = navigationAction.request.httpMethod {
                print("[WebView Request] Method: \(method)")
            }
            
            if let headers = navigationAction.request.allHTTPHeaderFields {
                print("[WebView Request] Headers: \(headers)")
            }
            
            if let bodyData = navigationAction.request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
                print("[WebView Request] Body: \(bodyString)")
            }
            print("==================================================")
            // --- [디버깅 코드 종료] ---

            // 기존 넷퍼넬 키 확인 로직은 주석 처리하거나 그대로 둘 수 있습니다.
            // 여기서는 테스트를 위해 잠시 주석 처리합니다.
            /*
            if let url = navigationAction.request.url, url.absoluteString.contains("netfunnelKey=") {
                if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                   let queryItems = components.queryItems {
                    for item in queryItems {
                        if item.name == "netfunnelKey", let key = item.value {
                            self.parent.onCompletion(key)
                            decisionHandler(.cancel)
                            return
                        }
                    }
                }
            }
            */
            
            // 모든 요청을 허용하여 웹뷰가 정상적으로 동작하도록 합니다.
            decisionHandler(.allow)
        }
    }
}