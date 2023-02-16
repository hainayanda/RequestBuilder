//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 15/2/23.
//

import Foundation
import Combine

public extension BaseURLRequestBuilder {
    func downloadTask(
        using session: URLSession = .shared,
        _ retryResponder: AsyncRequestRetryResponder<URL> = .default,
        _ stateResponder: AsyncRequestStateResponder<URL> = .default) -> AsyncRequest<URL> {
            DownloadAsyncURLRequest(request: rawRequest, session: session, retryResponder: retryResponder, stateResponder: stateResponder)
        }
}

public extension Data {
    func resumeDownload(
        using session: URLSession = .shared,
        _ retryResponder: AsyncRequestRetryResponder<URL> = .default,
        _ stateResponder: AsyncRequestStateResponder<URL> = .default) -> ResumableAsyncRequest<URL, Data> {
            DownloadAsyncURLRequest(resumeData: self, session: session, retryResponder: retryResponder, stateResponder: stateResponder)
        }
}

class DownloadAsyncURLRequest: ResumableAsyncRequest<URL, Data> {
    
    private var observation: NSKeyValueObservation!
    private var downloadTask: URLSessionDownloadTask!
    
    init(resumeData: Data,
         session: URLSession,
         retryResponder: AsyncRequestRetryResponder<URL>,
         stateResponder: AsyncRequestStateResponder<URL>) {
        super.init()
        sendRequest(resumeData: resumeData, session: session, retryResponder: retryResponder, stateResponder: stateResponder)
    }
    
    init(request: URLRequest,
         session: URLSession,
         retryResponder: AsyncRequestRetryResponder<URL>,
         stateResponder: AsyncRequestStateResponder<URL>) {
        super.init()
        sendRequest(request: request, session: session, retryResponder: retryResponder, stateResponder: stateResponder)
    }
    
    deinit { observation.invalidate() }
    
    override func cancel() async -> Data? {
        await downloadTask.cancelByProducingResumeData()
    }
    
    override func cancel() {
        downloadTask.cancel()
        super.cancel()
    }
    
    override func resume() {
        downloadTask.resume()
        super.resume()
    }
    
    override func suspend() {
        downloadTask.suspend()
        super.suspend()
    }
    
    private func sendRequest(
        request: URLRequest,
        session: URLSession,
        retryResponder: AsyncRequestRetryResponder<URL>,
        stateResponder: AsyncRequestStateResponder<URL>) {
            let downloadTask = session.downloadTask(with: request) { url, response, error in
                Task {
                    let requestResponse = URLRequestResponse(payload: url, response: response, error: nil)
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
                    self.sendRequest(request: request, session: session, retryResponder: retryResponder, stateResponder: stateResponder)
                }
            }
            self.observation = downloadTask.progress.observe(\.fractionCompleted) { [unowned self] progress, _ in
                self.progress = progress.fractionCompleted
            }
            self.downloadTask = downloadTask
            downloadTask.resume()
        }
    
    private func sendRequest(
        resumeData: Data,
        session: URLSession,
        retryResponder: AsyncRequestRetryResponder<URL>,
        stateResponder: AsyncRequestStateResponder<URL>) {
            let downloadTask = session.downloadTask(withResumeData: resumeData) { url, response, error in
                Task {
                    let requestResponse = URLRequestResponse(payload: url, response: response, error: nil)
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
                    self.sendRequest(resumeData: resumeData, session: session, retryResponder: retryResponder, stateResponder: stateResponder)
                }
            }
            self.observation = downloadTask.progress.observe(\.fractionCompleted) { [unowned self] progress, _ in
                self.progress = progress.fractionCompleted
            }
            self.downloadTask = downloadTask
            downloadTask.resume()
        }
    
}
