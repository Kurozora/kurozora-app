//
//  TrailerCaptionServer.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import Network

/// Serves subtitle documents to the app's own player over a loopback HTTP connection.
actor TrailerCaptionServer {
	// MARK: - Properties
	/// The shared server.
	static let shared = TrailerCaptionServer()

	/// The queue the listener and its connections run on.
	private let queue = DispatchQueue(label: "app.kurozora.trailer.caption-server")

	/// The listener accepting loopback connections.
	private var listener: NWListener?

	/// The port the listener accepted.
	private var port: UInt16?

	/// The callers waiting for the port.
	private var portWaiters: [CheckedContinuation<UInt16?, Never>] = []

	/// The published documents by path.
	private var documents: [String: Data] = [:]

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Publishes the given document at the given path.
	///
	/// - Parameters:
	///    - document: The document's text.
	///    - path: The path the document is served at.
	///
	/// - Returns: The loopback address the document is served at.
	func publish(_ document: String, at path: String) async -> URL? {
		self.documents[path] = Data(document.utf8)

		guard let port = await self.readyPort() else { return nil }
		return URL(string: "http://127.0.0.1:\(port)\(path)")
	}

	/// Returns the listener's port once it is accepting connections.
	///
	/// - Returns: The port.
	private func readyPort() async -> UInt16? {
		if let port = self.port {
			return port
		}

		self.startIfNeeded()
		guard self.listener != nil else { return nil }

		return await withCheckedContinuation { continuation in
			self.portWaiters.append(continuation)
		}
	}

	/// Starts the listener when it is not running.
	private func startIfNeeded() {
		guard self.listener == nil else { return }

		let parameters = NWParameters.tcp
		parameters.requiredLocalEndpoint = NWEndpoint.hostPort(host: "127.0.0.1", port: .any)

		guard let listener = try? NWListener(using: parameters) else {
			print("----- [Trailer] The caption server could not listen")
			return
		}

		listener.stateUpdateHandler = { state in
			Task { await TrailerCaptionServer.shared.handle(state, of: listener) }
		}
		listener.newConnectionHandler = { connection in
			Task { await TrailerCaptionServer.shared.serve(connection) }
		}
		listener.start(queue: self.queue)
		self.listener = listener
	}

	/// Records the listener's state.
	///
	/// - Parameters:
	///    - state: The listener's new state.
	///    - listener: The listener reporting the state.
	private func handle(_ state: NWListener.State, of listener: NWListener) {
		switch state {
		case .ready:
			self.port = listener.port?.rawValue
			self.resumePortWaiters()
		case .failed(let error):
			print("----- [Trailer] The caption server stopped: \(error)")
			self.listener = nil
			self.port = nil
			self.resumePortWaiters()
		case .cancelled:
			self.listener = nil
			self.port = nil
			self.resumePortWaiters()
		default:
			break
		}
	}

	/// Hands the port to every waiting caller.
	private func resumePortWaiters() {
		let waiters = self.portWaiters
		self.portWaiters = []

		for waiter in waiters {
			waiter.resume(returning: self.port)
		}
	}

	/// Answers the request arriving on the given connection.
	///
	/// - Parameter connection: The accepted connection.
	private func serve(_ connection: NWConnection) {
		connection.start(queue: self.queue)
		connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { content, _, _, error in
			Task { await TrailerCaptionServer.shared.respond(to: content, error: error, on: connection) }
		}
	}

	/// Writes the response for the given request to the given connection.
	///
	/// - Parameters:
	///    - content: The request's bytes.
	///    - error: The error the connection reported.
	///    - connection: The connection to answer on.
	private func respond(to content: Data?, error: NWError?, on connection: NWConnection) {
		guard let content = content, error == nil, let request = String(bytes: content, encoding: .utf8) else {
			connection.cancel()
			return
		}

		let requestLine = request.components(separatedBy: "\r\n").first ?? ""
		let path = requestLine.split(separator: " ").dropFirst().first.map(String.init) ?? ""
		let response = self.response(forPath: path)

		connection.send(content: response, completion: .contentProcessed { _ in
			connection.cancel()
		})
	}

	/// Returns the HTTP response for the given path.
	///
	/// - Parameter path: The requested path.
	///
	/// - Returns: The response's bytes.
	private func response(forPath path: String) -> Data {
		guard let document = self.documents[path] else {
			return Data("HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\nConnection: close\r\n\r\n".utf8)
		}

		var response = Data("HTTP/1.1 200 OK\r\nContent-Type: text/vtt; charset=utf-8\r\nContent-Length: \(document.count)\r\nAccept-Ranges: none\r\nConnection: close\r\n\r\n".utf8)
		response.append(document)
		return response
	}
}
