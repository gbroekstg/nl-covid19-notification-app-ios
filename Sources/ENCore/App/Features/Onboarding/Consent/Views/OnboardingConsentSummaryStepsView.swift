/*
 * Copyright (c) 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

final class OnboardingConsentSummaryStepsView: View {

    private let consentSummarySteps: [OnboardingConsentSummaryStep]
    var consentSummaryStepViews: [OnboardingConsentSummaryStepView] = []

    // MARK: - Lifecycle

    required init(with steps: [OnboardingConsentSummaryStep], theme: Theme) {
        self.consentSummarySteps = steps
        self.consentSummaryStepViews = consentSummarySteps.map { OnboardingConsentSummaryStepView(with: $0, theme: theme) }
        super.init(theme: theme)
    }

    override func build() {
        super.build()

        backgroundColor = .clear
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false

        consentSummaryStepViews.forEach { addSubview($0) }
    }

    override func setupConstraints() {
        super.setupConstraints()

        var constraints = [[NSLayoutConstraint]()]

        for (index, consentSummaryStepView) in self.consentSummaryStepViews.enumerated() {

            consentSummaryStepView.constraints.forEach { consentSummaryStepView.removeConstraint($0) }

            constraints.append([
                consentSummaryStepView.topAnchor.constraint(equalTo: index == 0 ? topAnchor : self.consentSummaryStepViews[index - 1].bottomAnchor, constant: 0),
                consentSummaryStepView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                consentSummaryStepView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                consentSummaryStepView.heightAnchor.constraint(greaterThanOrEqualToConstant: self.consentSummaryStepViews[index].estimateHeight)
            ])

            consentSummaryStepView.setupConstraints()
        }

        for constraint in constraints { NSLayoutConstraint.activate(constraint) }
    }
}
