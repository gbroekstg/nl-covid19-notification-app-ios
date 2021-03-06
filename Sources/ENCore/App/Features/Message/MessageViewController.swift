/*
 * Copyright (c) 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import SnapKit
import UIKit

/// @mockable
protocol MessageViewControllable: ViewControllable {}

final class MessageViewController: ViewController, MessageViewControllable, UIAdaptivePresentationControllerDelegate {

    struct Message {
        let title: String
        let body: String
    }

    // MARK: - Init

    init(listener: MessageListener, theme: Theme, message: Message) {
        self.listener = listener
        self.message = message

        super.init(theme: theme)
    }

    // MARK: - ViewController Lifecycle

    override func loadView() {
        self.view = internalView
        self.view.frame = UIScreen.main.bounds
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localization.string(for: "message.title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                            target: self,
                                                            action: #selector(didTapCloseButton(sender:)))

        internalView.infoView.actionHandler = {
            let urlString = "tel://08001202"
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("🔥 Unable to open \(urlString)")
            }
        }
    }

    // MARK: - UIAdaptivePresentationControllerDelegate

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        listener?.messageWantsDismissal(shouldDismissViewController: false)
    }

    // MARK: - Private

    private let message: Message

    private weak var listener: MessageListener?
    private lazy var internalView: MessageView = {
        MessageView(theme: self.theme, title: self.message.title, body: self.message.body)
    }()

    @objc private func didTapCloseButton(sender: UIBarButtonItem) {
        listener?.messageWantsDismissal(shouldDismissViewController: true)
    }
}

private final class MessageView: View {

    fileprivate let infoView: InfoView
    private let title: String
    private let body: String

    // MARK: - Init

    init(theme: Theme, title: String, body: String) {
        self.title = title
        self.body = body
        let config = InfoViewConfig(actionButtonTitle: Localization.string(for: "message.button.title"),
                                    headerImage: Image.named("MessageHeader"))
        self.infoView = InfoView(theme: theme, config: config)
        super.init(theme: theme)
    }

    // MARK: - Overrides

    override func build() {
        super.build()

        infoView.addSections([
            message(),
            complaints(),
            doCoronaTest(),
            info()
        ])

        addSubview(infoView)
    }

    override func setupConstraints() {
        super.setupConstraints()

        infoView.snp.makeConstraints { (maker: ConstraintMaker) in
            maker.edges.equalToSuperview()
        }
    }

    // MARK: - Private

    private func message() -> View {
        InfoSectionTextView(theme: theme, title: title, content: NSAttributedString(string: body))
    }

    private func complaints() -> View {
        let list = [
            Localization.string(for: "moreInformation.complaints.item1"),
            Localization.string(for: "moreInformation.complaints.item2"),
            Localization.string(for: "moreInformation.complaints.item3"),
            Localization.string(for: "moreInformation.complaints.item4")
        ]
        let bulletList = NSAttributedString.bulletList(list, theme: theme, font: theme.fonts.body)
        let content = Localization.attributedString(for: "moreInformation.complaints.content")

        let string = NSMutableAttributedString()
        string.append(bulletList)
        string.append(content)
        return InfoSectionTextView(theme: theme,
                                   title: Localization.string(for: "moreInformation.complaints.title"),
                                   content: string)
    }

    private func doCoronaTest() -> View {
        InfoSectionTextView(theme: theme,
                            title: Localization.string(for: "moreInformation.receivedNotification.doCoronaTest.title"),
                            content: Localization.attributedString(for: "moreInformation.receivedNotification.doCoronaTest.content"))
    }

    private func info() -> View {
        let string = Localization.attributedString(for: "moreInformation.info.title")
        return InfoSectionCalloutView(theme: theme, content: string)
    }
}
