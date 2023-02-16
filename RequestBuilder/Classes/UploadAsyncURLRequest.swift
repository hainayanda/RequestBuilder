//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 15/2/23.
//

import Foundation
import Combine

public extension BaseURLRequestBuilder {
    func uploadTask(
        using session: URLSession = .shared,
        data: Data,
        _ retryResponder: AsyncRequestRetryResponder<Data> = .default,
        _ stateResponder: AsyncRequestStateResponder<Data> = .default) -> AsyncRequest<Data> {
            UploadAsyncURLRequest(request: rawRequest, session: session, uploadData: data, retryResponder: retryResponder, stateResponder: stateResponder)
        }
    
    func uploadTask(
        using session: URLSession = .shared,
        fileURL: URL,
        _ retryResponder: AsyncRequestRetryResponder<Data> = .default,
        _ stateResponder: AsyncRequestStateResponder<Data> = .default) -> AsyncRequest<Data> {
            UploadAsyncURLRequest(request: rawRequest, session: session, fileURL: fileURL, retryResponder: retryResponder, stateResponder: stateResponder)
        }
}

class UploadAsyncURLRequest: AsyncRequest<Data> {
    
    private var observation: NSKeyValueObservation!
    private var uploadTask: URLSessionUploadTask!
    
    init(request: URLRequest, session: URLSession, uploadData: Data,
         retryResponder: AsyncRequestRetryResponder<Data>,
         stateResponder: AsyncRequestStateResponder<Data>) {
        super.init()
        sendRequest(request: request, session: session, uploadData: uploadData, retryResponder: retryResponder, stateResponder: stateResponder)
    }
    
    init(request: URLRequest, session: URLSession, fileURL: URL,
         retryResponder: AsyncRequestRetryResponder<Data>,
         stateResponder: AsyncRequestStateResponder<Data>) {
        super.init()
        sendRequest(request: request, session: session, fileURL: fileURL, retryResponder: retryResponder, stateResponder: stateResponder)
    }
    
    deinit { observation.invalidate() }
    
    override func cancel() {
        uploadTask.cancel()
        super.cancel()
    }
    
    override func resume() {
        uploadTask.resume()
        super.resume()
    }
    
    override func suspend() {
        uploadTask.suspend()
        super.suspend()
    }
    
    private func sendRequest(
        request: URLRequest,
        session: URLSession,
        fileURL: URL,
        retryResponder: AsyncRequestRetryResponder<Data>,
        stateResponder: AsyncRequestStateResponder<Data>) {
            let uploadTask = session.uploadTask(with: request, fromFile: fileURL) { data, response, error in
                Task {
                    let requestResponse = URLRequestResponse(payload: data, response: response, error: nil)
                    let state = stateResponder.asyncRequest(self, stateFor: requestResponse)
                    let shouldRetry = await retryResponder.asyncRequest(self, shouldRetryFor: state)
                    guard shouldRetry else {
                        switch state {
                        case .success(let response):
                            self.state = .completed(response)
                        case .failing(let response):
                            self.state = .fail(response)
                        }
                        return
                    }
                    self.observation.invalidate()
                    self.sendRequest(
                        request: request,
                        session: session,
                        fileURL: fileURL,
                        retryResponder: retryResponder,
                        stateResponder: stateResponder
                    )
                }
            }
            self.observation = uploadTask.progress.observe(\.fractionCompleted) { [unowned self] progress, _ in
                self.progress = progress.fractionCompleted
            }
            self.uploadTask = uploadTask
            uploadTask.resume()
        }
    
    private func sendRequest(
        request: URLRequest,
        session: URLSession,
        uploadData: Data,
        retryResponder: AsyncRequestRetryResponder<Data>,
        stateResponder: AsyncRequestStateResponder<Data>) {
            let uploadTask = session.uploadTask(with: request, from: uploadData) { data, response, error in
                Task {
                    let requestResponse = URLRequestResponse(payload: data, response: response, error: nil)
                    let state = stateResponder.asyncRequest(self, stateFor: requestResponse)
                    let shouldRetry = await retryResponder.asyncRequest(self, shouldRetryFor: state)
                    guard shouldRetry else {
                        switch state {
                        case .success(let response):
                            self.state = .completed(response)
                        case .failing(let response):
                            self.state = .fail(response)
                        }
                        return
                    }
                    self.observation.invalidate()
                    self.sendRequest(
                        request: request,
                        session: session,
                        uploadData: uploadData,
                        retryResponder: retryResponder,
                        stateResponder: stateResponder
                    )
                }
            }
            self.observation = uploadTask.progress.observe(\.fractionCompleted) { [unowned self] progress, _ in
                self.progress = progress.fractionCompleted
            }
            self.uploadTask = uploadTask
            uploadTask.resume()
        }
    
}
