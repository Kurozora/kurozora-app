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

	/// The full model behind a finished game's subject, keyed by kind.
	private enum SubjectModel {
		/// The subject is a show.
		case show(Show)

		/// The subject is a literature.
		case literature(Literature)

		/// The subject is a game.
		case game(Game)

		/// The subject is a character.
		case character(Character)

		/// The subject is a person.
		case person(Person)

		/// The subject is a studio.
		case studio(Studio)

		/// The subject is a song.
		case song(Song)
	}

	// MARK: - Views
	private let scrollView = UIScrollView()
	private let contentStackView = UIStackView()
	private let hintView = KotodamaHintView()
	private let imageHintView = KotodamaImageHintView()
	private let boardView = KotodamaBoardView()
	private let messageLabel = UILabel()
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

	/// The full model behind the finished game's subject, used to build its context menu.
	private var subjectModel: SubjectModel?

	/// Whether the finished game's share grid preview has been fetched.
	private var didFetchShareGrid = false

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

		self.messageLabel.textAlignment = .center
		self.messageLabel.numberOfLines = 2
		self.messageLabel.font = .preferredFont(forTextStyle: .footnote)
		self.messageLabel.adjustsFontForContentSizeCategory = true
		self.messageLabel.theme_textColor = KThemePicker.subTextColor.rawValue

		self.keyboardView.delegate = self
		self.resultView.delegate = self
		self.leaderboardPeekView.delegate = self

		// Only the daily carries a streak and a leaderboard, matching the website.
		self.streakView.isHidden = !self.isDaily
		self.leaderboardPeekView.isHidden = !self.isDaily

		// The board and keyboard own the top of the screen; the hint slots sit below,
		// still permanently reserved so revealing a hint never shifts the layout.
		self.contentStackView.addArrangedSubview(self.boardView)
		self.contentStackView.addArrangedSubview(self.messageLabel)
		self.contentStackView.addArrangedSubview(self.keyboardView)
		self.contentStackView.addArrangedSubview(self.hintView)
		self.contentStackView.addArrangedSubview(self.imageHintView)
		self.contentStackView.addArrangedSubview(self.resultView)
		self.contentStackView.addArrangedSubview(self.streakView)
		self.contentStackView.addArrangedSubview(self.leaderboardPeekView)

		self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
		self.activityIndicatorView.prefersHidden = true
		self.view.addSubview(self.activityIndicatorView)

		let contentGuide = self.scrollView.contentLayoutGuide
		let frameGuide = self.scrollView.frameLayoutGuide
		let safeAreaGuide = self.view.safeAreaLayoutGuide

		NSLayoutConstraint.activate([
			self.activityIndicatorView.centerXAnchor.constraint(equalTo: safeAreaGuide.centerXAnchor),
			self.activityIndicatorView.centerYAnchor.constraint(equalTo: safeAreaGuide.centerYAnchor),
			self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			contentGuide.widthAnchor.constraint(equalTo: frameGuide.widthAnchor),
			self.contentStackView.topAnchor.constraint(equalTo: contentGuide.topAnchor, constant: 16),
			self.contentStackView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor, constant: -24),
			self.contentStackView.centerXAnchor.constraint(equalTo: contentGuide.centerXAnchor),
			self.contentStackView.widthAnchor.constraint(equalTo: safeAreaGuide.widthAnchor, constant: -32),
			self.hintView.widthAnchor.constraint(equalTo: self.contentStackView.widthAnchor),
			self.imageHintView.widthAnchor.constraint(equalTo: self.contentStackView.widthAnchor),
			self.messageLabel.widthAnchor.constraint(equalTo: self.contentStackView.widthAnchor),
			self.messageLabel.heightAnchor.constraint(equalToConstant: 36),
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
		self.hintView.configure(using: game.word?.attributes.hint)
		self.keyboardView.isHidden = isFinished
		self.hintView.isHidden = isFinished
		self.resultView.isHidden = !isFinished
		self.imageHintView.isHidden = isFinished

		if isFinished {
			self.resultView.configure(using: game)

			if self.subjectModel == nil, let subject = game.word?.subject {
				Task { [weak self] in
					await self?.fetchSubjectModel(for: subject)
				}
			}

			if !self.didFetchShareGrid {
				self.didFetchShareGrid = true

				Task { [weak self] in
					await self?.fetchShareGrid(gameID: game.id)
				}
			}
		} else {
			self.imageHintView.configure(using: game.word?.attributes.poster?.url, kind: game.word?.subjectKind)
		}
	}

	/// Fetches the share grid shown as a preview beneath the finished game's outcome.
	///
	/// - Parameter gameID: The id of the finished game.
	private func fetchShareGrid(gameID: KurozoraItemID) async {
		do {
			let response = try await KService.kotodamaShareGrid(gameID: gameID).response()

			guard let shareGrid = response.data.first else {
				self.resultView.hideShareGridPreview()
				return
			}

			self.resultView.showShareGridPreview(text: shareGrid.attributes.text)
		} catch {
			self.resultView.hideShareGridPreview()
		}
	}

	/// Fetches the full model behind the finished game's subject, used to build its context menu.
	///
	/// - Parameter subject: The identity of the subject to fetch.
	private func fetchSubjectModel(for subject: KotodamaSubjectIdentity) async {
		do {
			switch subject.kind {
			case .shows:
				guard let show = try await KService.detail(ShowIdentity(id: subject.id)).response().data.first else { return }
				self.subjectModel = .show(show)
			case .literatures:
				guard let literature = try await KService.detail(LiteratureIdentity(id: subject.id)).response().data.first else { return }
				self.subjectModel = .literature(literature)
			case .games:
				guard let game = try await KService.detail(GameIdentity(id: subject.id)).response().data.first else { return }
				self.subjectModel = .game(game)
			case .characters:
				guard let character = try await KService.detail(CharacterIdentity(id: subject.id)).response().data.first else { return }
				self.subjectModel = .character(character)
			case .people:
				guard let person = try await KService.detail(PersonIdentity(id: subject.id)).response().data.first else { return }
				self.subjectModel = .person(person)
			case .studios:
				guard let studio = try await KService.detail(StudioIdentity(id: subject.id)).response().data.first else { return }
				self.subjectModel = .studio(studio)
			case .songs:
				guard let song = try await KService.detail(SongIdentity(id: subject.id)).response().data.first else { return }
				self.subjectModel = .song(song)
			case nil:
				return
			}
		} catch {
			return
		}
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
		guard let game = self.game else { return }
		guard !self.isSubmitting, self.pendingGuess.count < (game.word?.attributes.length ?? Kotodama.wordLength) else { return }

		self.pendingGuess.append(letter)
		self.messageLabel.text = nil
		self.render(animated: false)
	}

	/// Removes the last letter from the pending guess.
	private func deleteLetter() {
		guard !self.isSubmitting, !self.pendingGuess.isEmpty else { return }

		self.pendingGuess.removeLast()
		self.messageLabel.text = nil
		self.render(animated: false)
	}

	/// Submits the pending guess.
	private func submitGuess() {
		guard let game = self.game, !self.isSubmitting else { return }

		guard self.pendingGuess.count == (game.word?.attributes.length ?? Kotodama.wordLength) else {
			self.messageLabel.text = L10n.kotodamaIncompleteGuess
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
				self.messageLabel.text = nil
				self.render(animated: true)

				if game.attributes.status?.isFinished ?? false {
					NotificationCenter.default.post(name: .KKotodamaGameDidFinish, object: nil)

					if game.attributes.mode == .daily {
						await self.reloadDailySections()
					}
				}
			} catch let error as APIError {
				self.isSubmitting = false
				self.messageLabel.text = error.message
				self.shakeActiveRow()
			} catch {
				self.isSubmitting = false
				self.messageLabel.text = error.localizedDescription
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
				self.subjectModel = nil
				self.didFetchShareGrid = false
				self.messageLabel.text = nil
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

// MARK: - KotodamaResultViewDelegate
extension KotodamaGameViewController: KotodamaResultViewDelegate {
	func kotodamaResultViewDidPressShare(_ resultView: KotodamaResultView) {
		guard let game = self.game else { return }

		Task { [weak self] in
			guard let self = self else { return }

			do {
				let response = try await KService.kotodamaShareGrid(gameID: game.id).response()

				guard let shareGrid = response.data.first else { return }

				let activityViewController = UIActivityViewController(
					activityItems: [shareGrid.attributes.text],
					applicationActivities: nil
				)
				activityViewController.popoverPresentationController?.sourceView = resultView
				self.present(activityViewController, animated: true)
			} catch let error as APIError {
				self.presentAlertController(title: L10n.kotodama, message: error.message)
			} catch {
				self.presentAlertController(title: L10n.kotodama, message: error.localizedDescription)
			}
		}
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
		guard let subjectModel = self.subjectModel else { return nil }

		switch subjectModel {
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
