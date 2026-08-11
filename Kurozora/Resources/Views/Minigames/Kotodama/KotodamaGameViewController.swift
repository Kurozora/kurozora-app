//
//  KotodamaGameViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class KotodamaGameViewController: KViewController {
	// MARK: - Enums
	/// The set of puzzles the screen can open with.
	enum Puzzle {
		/// A game the caller already holds.
		case game(KotodamaGame)

		/// Today's puzzle, fetched by the screen itself.
		case daily

		/// A practice puzzle, fetched by the screen itself.
		case unlimited

		/// A past puzzle, fetched by the screen itself.
		case archive(Date)
	}

	// MARK: - Views
	private let scrollView = UIScrollView()
	private let contentStackView = UIStackView()
	private let kindLabel = UILabel()
	private let boardView = KotodamaBoardView()
	private let hintRowView = KotodamaHintRowView()
	private let keyboardView = KotodamaKeyboardView()
	private let resultView = KotodamaResultView()
	private let streakView = KotodamaStreakView()
	private let leaderboardPeekView = KotodamaLeaderboardPeekView()
	private let activityIndicatorView = KActivityIndicatorView()

	// MARK: - Properties
	/// The number of fastest solves shown beneath the board.
	private static let peekLimit = 3

	/// The puzzle the screen opened with.
	private let puzzle: Puzzle

	/// The game being played.
	private var game: KotodamaGame?

	/// The player's record.
	private var stats: KotodamaUserStats?

	/// The fastest solves of today's puzzle.
	private var topEntries: [KotodamaLeaderboardEntry]

	/// The catalog entry behind the finished game's answer.
	private var subject: KotodamaSubject?

	/// The letters typed but not yet submitted.
	private var pendingGuess: String = ""

	/// Whether a guess is in flight.
	private var isSubmitting: Bool = false

	/// Whether the screen shows today's puzzle.
	private var isDaily: Bool {
		switch self.puzzle {
		case .game(let game):
			return game.attributes.mode == .daily
		case .daily:
			return true
		case .unlimited, .archive:
			return false
		}
	}

	// MARK: - Initializers
	/// Creates a screen for the given puzzle.
	///
	/// - Parameters:
	///    - puzzle: The puzzle to play.
	///    - stats: The player's record, when the caller already holds it.
	///    - topEntries: The fastest solves of today's puzzle, when the caller already holds them.
	init(puzzle: Puzzle, stats: KotodamaUserStats? = nil, topEntries: [KotodamaLeaderboardEntry] = []) {
		self.puzzle = puzzle
		self.stats = stats
		self.topEntries = topEntries

		if case .game(let game) = puzzle {
			self.game = game
		}

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = self.screenTitle
		self.configureView()

		guard self.game != nil else {
			self.activityIndicatorView.prefersHidden = false

			Task { [weak self] in
				await self?.fetchPuzzle()
			}
			return
		}

		self.render(animated: false)
		self.renderDailySections()
	}

	override var canBecomeFirstResponder: Bool {
		return true
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		self.becomeFirstResponder()
	}

	override var keyCommands: [UIKeyCommand]? {
		let inputs = "abcdefghijklmnopqrstuvwxyz".map(String.init) + ["\r", UIKeyCommand.inputDelete]
		let commands = inputs.map { input in
			UIKeyCommand(input: input, modifierFlags: [], action: #selector(self.hardwareKeyPressed(_:)))
		}
		commands.forEach { $0.wantsPriorityOverSystemBehavior = true }

		return commands
	}

	// MARK: - Functions
	/// The title shown for the game's mode.
	///
	/// The archive's date is known the moment the screen is pushed, so it renders immediately and
	/// never falls back to the generic title or swaps to a puzzle number once the fetch completes.
	private var screenTitle: String {
		switch self.puzzle {
		case .unlimited:
			return L10n.kotodamaUnlimited
		case .archive(let date):
			return Self.archiveDateFormatter.string(from: date)
		case .daily, .game:
			guard let puzzleNumber = self.game?.dailyPuzzle?.attributes.puzzleNumber else {
				return L10n.kotodama
			}

			return String(format: L10n.kotodamaDailyPuzzleNumber, puzzleNumber)
		}
	}

	/// Lays out the board, keyboard and result view.
	private func configureView() {
		self.scrollView.translatesAutoresizingMaskIntoConstraints = false
		self.scrollView.alwaysBounceVertical = true
		self.scrollView.contentInsetAdjustmentBehavior = .scrollableAxes
		self.view.addSubview(self.scrollView)

		self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
		self.contentStackView.axis = .vertical
		self.contentStackView.alignment = .center
		self.contentStackView.spacing = 16
		self.contentStackView.isHidden = self.game == nil
		self.scrollView.addSubview(self.contentStackView)

		self.kindLabel.textAlignment = .center
		self.kindLabel.numberOfLines = 1
		self.kindLabel.font = UIFontMetrics(forTextStyle: .caption1)
			.scaledFont(for: .systemFont(ofSize: 12, weight: .semibold))
		self.kindLabel.adjustsFontForContentSizeCategory = true
		self.kindLabel.theme_textColor = KThemePicker.subTextColor.rawValue

		self.keyboardView.delegate = self
		self.hintRowView.delegate = self
		self.resultView.delegate = self
		self.leaderboardPeekView.delegate = self

		// Only the daily carries a streak and a leaderboard, matching the website.
		self.streakView.isHidden = !self.isDaily
		self.leaderboardPeekView.isHidden = !self.isDaily

		// The hint row is reserved from the start so a hint arriving mid-game never shifts the layout.
		self.contentStackView.addArrangedSubview(self.kindLabel)
		self.contentStackView.addArrangedSubview(self.boardView)
		self.contentStackView.addArrangedSubview(self.hintRowView)
		self.contentStackView.addArrangedSubview(self.keyboardView)
		self.contentStackView.addArrangedSubview(self.resultView)
		self.contentStackView.addArrangedSubview(self.streakView)
		self.contentStackView.addArrangedSubview(self.leaderboardPeekView)

		self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
		self.activityIndicatorView.prefersHidden = true
		self.view.addSubview(self.activityIndicatorView)

		let contentGuide = self.scrollView.contentLayoutGuide
		let frameGuide = self.scrollView.frameLayoutGuide
		let safeAreaGuide = self.view.safeAreaLayoutGuide
		let readableGuide = self.view.readableContentGuide

		NSLayoutConstraint.activate([
			self.activityIndicatorView.centerXAnchor.constraint(equalTo: readableGuide.centerXAnchor),
			self.activityIndicatorView.centerYAnchor.constraint(equalTo: safeAreaGuide.centerYAnchor),
			self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			contentGuide.widthAnchor.constraint(equalTo: frameGuide.widthAnchor),
			self.contentStackView.topAnchor.constraint(equalTo: contentGuide.topAnchor, constant: 16),
			self.contentStackView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor, constant: -24),
			self.contentStackView.centerXAnchor.constraint(equalTo: readableGuide.centerXAnchor),
			self.contentStackView.widthAnchor.constraint(equalTo: readableGuide.widthAnchor),
			self.kindLabel.widthAnchor.constraint(equalTo: self.contentStackView.widthAnchor),
			self.hintRowView.widthAnchor.constraint(equalTo: self.contentStackView.widthAnchor),
			self.resultView.widthAnchor.constraint(equalTo: self.contentStackView.widthAnchor),
			self.streakView.widthAnchor.constraint(equalTo: self.contentStackView.widthAnchor),
			self.leaderboardPeekView.widthAnchor.constraint(equalTo: self.contentStackView.widthAnchor),
			self.keyboardView.widthAnchor.constraint(lessThanOrEqualTo: self.contentStackView.widthAnchor),
			self.keyboardView.widthAnchor.constraint(lessThanOrEqualToConstant: KotodamaKeyboardView.maximumWidth)
		])

		let keyboardWidthConstraint = self.keyboardView.widthAnchor.constraint(
			equalToConstant: KotodamaKeyboardView.maximumWidth
		)
		keyboardWidthConstraint.priority = .defaultHigh
		keyboardWidthConstraint.isActive = true
	}

	/// Fetches the puzzle the screen opened with.
	private func fetchPuzzle() async {
		do {
			switch self.puzzle {
			case .game:
				return
			case .daily:
				async let statsResponse = try? await KService.myKotodamaStats().response()
				async let leaderboardResponse = try? await KService
					.kotodamaDailyLeaderboard(limit: Self.peekLimit)
					.response()

				let puzzleResponse = try await KService.kotodamaDaily().response()
				self.game = puzzleResponse.data.first
				self.stats = await statsResponse?.data.first
				self.topEntries = await leaderboardResponse?.data ?? []
			case .unlimited:
				let response = try await KService.kotodamaUnlimited().response()
				self.game = response.data.first
			case .archive(let date):
				let response = try await KService.kotodamaArchive(on: date).response()
				self.game = response.data.first
			}
		} catch let error as APIError {
			self.activityIndicatorView.prefersHidden = true
			self.presentAlertController(title: L10n.kotodama, message: error.message)
			return
		} catch {
			self.activityIndicatorView.prefersHidden = true
			self.presentAlertController(title: L10n.kotodama, message: error.localizedDescription)
			return
		}

		self.activityIndicatorView.prefersHidden = true
		self.contentStackView.isHidden = false
		self.title = self.screenTitle
		self.render(animated: false)
		self.renderDailySections()
	}

	/// Draws the current game state.
	///
	/// - Parameter animated: Whether newly revealed tiles should flip.
	private func render(animated: Bool) {
		guard let game = self.game else { return }

		let state = KotodamaBoardState(game: game, pendingGuess: self.pendingGuess)
		let attributes = game.attributes
		let isFinished = attributes.status?.isFinished ?? false

		self.boardView.configure(using: state.rows, animated: animated)
		self.keyboardView.configure(using: state.keyboard)
		self.kindLabel.text = game.word?.subjectKind?.stringValue ?? L10n.kotodamaSubjectWord
		self.hintRowView.configure(
			hint: game.word?.attributes.hint,
			secondaryHint: game.word?.attributes.secondaryHint,
			posterURL: game.word?.attributes.poster?.url,
			kind: game.word?.subjectKind
		)
		self.keyboardView.isHidden = isFinished
		self.hintRowView.isHidden = isFinished
		self.resultView.isHidden = !isFinished

		if isFinished {
			self.resultView.configure(using: game)

			if self.subject == nil, let identity = game.word?.subject {
				Task { [weak self] in
					await self?.fetchSubject(for: identity)
				}
			}

			self.resultView.showShareGridPreview(text: KotodamaShareGrid.text(for: game))
		}
	}

	/// Fetches the catalog entry behind the finished game's answer.
	///
	/// - Parameter identity: The identity of the subject to fetch.
	private func fetchSubject(for identity: KotodamaSubjectIdentity) async {
		guard let kind = identity.kind else { return }

		self.subject = await KotodamaSubject(kind: kind, subjectID: identity.id)
		self.resultView.showSubject(self.subject)
	}

	/// Draws the record and fastest solves shown beneath the board.
	private func renderDailySections() {
		guard self.isDaily else { return }

		self.streakView.configure(using: self.stats)
		self.leaderboardPeekView.configure(using: self.topEntries)
	}

	/// Refreshes the record and fastest solves after the game ends.
	private func reloadDailySections() async {
		if let statsResponse = try? await KService.myKotodamaStats().response() {
			self.stats = statsResponse.data.first
		}

		if let leaderboardResponse = try? await KService
			.kotodamaDailyLeaderboard(limit: Self.peekLimit)
			.response() {
			self.topEntries = leaderboardResponse.data
		}

		self.renderDailySections()
	}

	/// Appends a letter to the pending guess.
	///
	/// - Parameter letter: The letter to append.
	private func append(letter: Swift.Character) {
		self.hintRowView.show(message: nil)

		guard let game = self.game else { return }
		guard !self.isSubmitting, self.pendingGuess.count < (game.word?.attributes.length ?? Kotodama.wordLength) else { return }

		self.pendingGuess.append(letter)
		self.render(animated: false)
	}

	/// Removes the last letter from the pending guess.
	private func deleteLetter() {
		self.hintRowView.show(message: nil)

		guard !self.isSubmitting, !self.pendingGuess.isEmpty else { return }

		self.pendingGuess.removeLast()
		self.render(animated: false)
	}

	/// Submits the pending guess.
	private func submitGuess() {
		guard let game = self.game, !self.isSubmitting else { return }

		guard self.pendingGuess.count == (game.word?.attributes.length ?? Kotodama.wordLength) else {
			self.hintRowView.show(message: L10n.kotodamaIncompleteGuess)
			self.shakeActiveRow()
			return
		}

		self.isSubmitting = true

		Task { [weak self] in
			guard let self = self else { return }

			do {
				let response = try await KService
					.submitKotodamaGuess(gameID: game.id, guess: self.pendingGuess)
					.response()

				self.isSubmitting = false

				guard let game = response.data.first else { return }

				self.pendingGuess = ""
				self.game = game
				self.hintRowView.show(message: nil)
				self.render(animated: true)

				if game.attributes.status?.isFinished ?? false {
					if game.attributes.mode?.isRanked ?? false {
						NotificationCenter.default.post(name: .KKotodamaGameDidFinish, object: nil)
					}

					if game.attributes.mode == .daily {
						await self.reloadDailySections()
					}
				}
			} catch let error as APIError {
				self.isSubmitting = false
				self.hintRowView.show(message: error.message)
				self.shakeActiveRow()
			} catch {
				self.isSubmitting = false
				self.hintRowView.show(message: error.localizedDescription)
				self.shakeActiveRow()
			}
		}
	}

	/// Shakes the row accepting input.
	private func shakeActiveRow() {
		guard let game = self.game else { return }

		let state = KotodamaBoardState(game: game, pendingGuess: self.pendingGuess)

		guard let activeRowIndex = state.activeRowIndex else { return }

		self.boardView.shakeRow(at: activeRowIndex)
		UINotificationFeedbackGenerator().notificationOccurred(.error)
	}

	/// Starts another practice game.
	private func startNewWord() {
		Task { [weak self] in
			guard let self = self else { return }

			do {
				let response = try await KService.kotodamaUnlimited().response()

				guard let game = response.data.first else { return }

				self.pendingGuess = ""
				self.game = game
				self.subject = nil
				self.hintRowView.show(message: nil)
				self.title = self.screenTitle
				self.render(animated: false)
			} catch let error as APIError {
				self.presentAlertController(title: L10n.kotodama, message: error.message)
			} catch {
				self.presentAlertController(title: L10n.kotodama, message: error.localizedDescription)
			}
		}
	}

	/// Handles a key press from a hardware keyboard.
	///
	/// - Parameter sender: The key command that was matched.
	@objc private func hardwareKeyPressed(_ sender: UIKeyCommand) {
		guard let input = sender.input else { return }

		switch input {
		case "\r":
			self.submitGuess()
		case UIKeyCommand.inputDelete:
			self.deleteLetter()
		default:
			guard let letter = input.uppercased().first else { return }
			self.append(letter: letter)
		}
	}
}

// MARK: - KotodamaKeyboardViewDelegate
extension KotodamaGameViewController: KotodamaKeyboardViewDelegate {
	func keyboardView(_ keyboardView: KotodamaKeyboardView, didPress key: KotodamaKey) {
		switch key {
		case .letter(let letter):
			self.append(letter: letter)
		case .submit:
			self.submitGuess()
		case .delete:
			self.deleteLetter()
		}
	}
}

// MARK: - KotodamaHintRowViewDelegate
extension KotodamaGameViewController: KotodamaHintRowViewDelegate {
	func kotodamaHintRowViewDidPressThumbnail(_ hintRowView: KotodamaHintRowView) {
		guard let url = URL(string: self.game?.word?.attributes.poster?.url ?? "") else { return }
		let item = MediaItem(
			url: url,
			type: .image,
			title: nil,
			description: nil,
			author: nil,
			provider: nil,
			embedHTML: nil,
			extraInfo: nil
		)

		let mediaAlbumViewController = MediaAlbumViewController(items: [item], startIndex: 0)
		mediaAlbumViewController.transitionDelegateForThumbnail = self
		self.present(mediaAlbumViewController, animated: true)
	}
}

// MARK: - MediaTransitionDelegate
extension KotodamaGameViewController: MediaTransitionDelegate {
	func imageViewForMedia(at index: Int) -> UIImageView? {
		return self.hintRowView.thumbnailView
	}

	func scrollThumbnailIntoView(for index: Int) {}
}

// MARK: - KotodamaResultViewDelegate
extension KotodamaGameViewController: KotodamaResultViewDelegate {
	func kotodamaResultViewDidPressShare(_ resultView: KotodamaResultView) {
		guard let game = self.game else { return }

		let activityViewController = UIActivityViewController(
			activityItems: [KotodamaShareGrid.text(for: game)],
			applicationActivities: nil
		)
		activityViewController.popoverPresentationController?.sourceView = resultView
		self.present(activityViewController, animated: true)
	}

	func kotodamaResultViewDidPressSubject(_ resultView: KotodamaResultView) {
		guard let subject = self.game?.word?.subject, let kind = subject.kind else { return }

		self.show(kind.detailsViewController(for: subject.id), sender: nil)
	}

	func kotodamaResultViewDidPressNewWord(_ resultView: KotodamaResultView) {
		self.startNewWord()
	}

	func kotodamaResultViewDidPressPlayUnlimited(_ resultView: KotodamaResultView) {
		self.show(KotodamaGameViewController(puzzle: .unlimited), sender: nil)
	}

	func kotodamaResultView(_ resultView: KotodamaResultView, wantsToShow viewController: UIViewController) {
		self.show(viewController, sender: nil)
	}

	func kotodamaResultViewContextMenuConfiguration(_ resultView: KotodamaResultView) -> UIContextMenuConfiguration? {
		guard let subject = self.subject else { return nil }

		switch subject {
		case .show(let show):
			return show.contextMenuConfiguration(in: self, userInfo: nil, sourceView: resultView, barButtonItem: nil)
		case .literature(let literature):
			return literature.contextMenuConfiguration(in: self, userInfo: nil, sourceView: resultView, barButtonItem: nil)
		case .game(let game):
			return game.contextMenuConfiguration(in: self, userInfo: nil, sourceView: resultView, barButtonItem: nil)
		case .character(let character):
			return character.contextMenuConfiguration(in: self, userInfo: nil, sourceView: resultView, barButtonItem: nil)
		case .person(let person):
			return person.contextMenuConfiguration(in: self, userInfo: nil, sourceView: resultView, barButtonItem: nil)
		case .studio(let studio):
			return studio.contextMenuConfiguration(in: self, userInfo: nil, sourceView: resultView, barButtonItem: nil)
		case .song(let song):
			return song.contextMenuConfiguration(in: self, userInfo: nil, sourceView: resultView, barButtonItem: nil)
		}
	}
}

// MARK: - KotodamaLeaderboardPeekViewDelegate
extension KotodamaGameViewController: KotodamaLeaderboardPeekViewDelegate {
	func kotodamaLeaderboardPeekViewDidPressSeeAll(_ peekView: KotodamaLeaderboardPeekView) {
		self.show(KotodamaLeaderboardsTableViewController(), sender: nil)
	}
}

// MARK: - Formatters
extension KotodamaGameViewController {
	/// The formatter used to show an archive puzzle's date as the screen's title.
	static let archiveDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter
	}()
}
