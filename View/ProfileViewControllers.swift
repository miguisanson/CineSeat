import UIKit

// module 2 shared account form view
// login create account and edit profile reuse the same field helpers
class AccountFormViewController: ScrollableViewController, UITextFieldDelegate {
    private weak var activeTextField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func makeTextField(
        placeholder: String,
        contentType: UITextContentType? = nil,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false
    ) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.textContentType = contentType
        textField.keyboardType = keyboardType
        textField.isSecureTextEntry = isSecure
        textField.autocapitalizationType = contentType == .name ? .words : .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .next
        textField.delegate = self
        textField.font = .systemFont(ofSize: 15)
        textField.backgroundColor = CineSeatTheme.card
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = CineSeatTheme.border.cgColor
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        textField.leftView = padding
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        textField.rightViewMode = .always
        return textField
    }

    func makeFormCard(title: String, fields: [UITextField]) -> CardView {
        let arrangedViews: [UIView] = [CineSeatTheme.captionLabel(title)] + fields
        let stack = UIStackView(arrangedSubviews: arrangedViews)
        stack.axis = .vertical
        stack.spacing = 10
        return makeCard(with: stack)
    }

    func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Unable to Continue",
            message: (error as? LocalizedError)?.errorDescription ?? error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if activeTextField === textField {
            activeTextField = nil
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = contentStack.allTextFields.first(where: { $0.tag == textField.tag + 1 }) {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let overlap = max(0, view.bounds.maxY - keyboardFrameInView.minY)
        let inset = overlap + 24
        scrollView.contentInset.bottom = inset
        scrollView.verticalScrollIndicatorInsets.bottom = inset

        guard let activeTextField else { return }
        let textFieldFrame = activeTextField.convert(activeTextField.bounds, to: scrollView)
        scrollView.scrollRectToVisible(textFieldFrame.insetBy(dx: 0, dy: -16), animated: true)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
}

// module 2 profile screen
// storyboard hstack buttons connect to login and create account actions
final class ProfileViewController: ScrollableViewController {
    // storyboard hstack containing the signed-out profile buttons
    @IBOutlet private weak var signedOutButtonStackView: UIStackView!
    // connected to the storyboard log in button in the profile scene
    @IBOutlet private weak var profileLoginButton: UIButton!
    // connected to the storyboard create account button in the profile scene
    @IBOutlet private weak var profileCreateAccountButton: UIButton!

    private let factory = AppFactory.shared
    private lazy var viewModel = factory.makeProfileViewModel()
    private var storyboardSignedOutViews: [UIView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureStoryboardButtons()
        storyboardSignedOutViews = contentStack.arrangedSubviews
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(authenticationChanged),
            name: viewModel.authenticationDidChangeNotification,
            object: nil
        )
        rebuildInterface()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        rebuildInterface()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func authenticationChanged() {
        rebuildInterface()
    }

    private func rebuildInterface() {
        clearContentStack()

        if let profile = viewModel.currentProfile {
            buildSignedInInterface(profile)
        } else {
            restoreSignedOutStoryboardInterface()
        }
    }

    private func clearContentStack() {
        contentStack.arrangedSubviews.forEach {
            contentStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    private func restoreSignedOutStoryboardInterface() {
        guard !storyboardSignedOutViews.isEmpty else {
            buildSignedOutInterface()
            return
        }
        storyboardSignedOutViews.forEach { contentStack.addArrangedSubview($0) }
    }

    private func configureStoryboardButtons() {
        signedOutButtonStackView?.axis = .horizontal
        signedOutButtonStackView?.spacing = 10
        signedOutButtonStackView?.distribution = .fillEqually
        configure(profileLoginButton, title: "Log In", isPrimary: true)
        configure(profileCreateAccountButton, title: "Create Account", isPrimary: false)
        profileLoginButton?.accessibilityIdentifier = "profileLoginButton"
        profileCreateAccountButton?.accessibilityIdentifier = "profileCreateAccountButton"
    }

    private func configure(_ button: UIButton?, title: String, isPrimary: Bool) {
        button?.setTitle(title, for: .normal)
        button?.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button?.layer.cornerRadius = 12
        button?.layer.borderWidth = isPrimary ? 0 : 1
        button?.layer.borderColor = CineSeatTheme.border.cgColor
        button?.backgroundColor = isPrimary ? CineSeatTheme.primaryText : CineSeatTheme.card
        button?.setTitleColor(isPrimary ? .white : CineSeatTheme.primaryText, for: .normal)
    }

    private func buildSignedOutInterface() {
        contentStack.addArrangedSubview(makePageTitle("Profile"))

        let iconView = UIImageView(image: UIImage(systemName: "person.crop.circle"))
        iconView.tintColor = CineSeatTheme.primaryText
        iconView.contentMode = .scaleAspectFit
        iconView.heightAnchor.constraint(equalToConstant: 96).isActive = true
        contentStack.addArrangedSubview(iconView)

        let welcomeLabel = UILabel()
        welcomeLabel.text = "Welcome to CineSeat"
        welcomeLabel.textAlignment = .center
        welcomeLabel.font = .systemFont(ofSize: 22, weight: .bold)
        welcomeLabel.textColor = CineSeatTheme.primaryText
        contentStack.addArrangedSubview(welcomeLabel)

        let messageLabel = UILabel()
        messageLabel.text = "Sign in to manage your account, keep your profile details, and quickly access your cinema bookings."
        messageLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 14)
        messageLabel.textColor = CineSeatTheme.secondaryText
        messageLabel.numberOfLines = 0
        contentStack.addArrangedSubview(messageLabel)

        let loginButton = CineSeatTheme.primaryButton(title: "Log In")
        loginButton.accessibilityIdentifier = "profileLoginButton"
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(loginButton)

        let createButton = CineSeatTheme.secondaryButton(title: "Create Account")
        createButton.accessibilityIdentifier = "profileCreateAccountButton"
        createButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(createButton)

        let privacyLabel = CineSeatTheme.captionLabel("Your password is stored securely in the iOS Keychain. Account data stays on this device.")
        privacyLabel.textAlignment = .center
        contentStack.addArrangedSubview(makeCard(with: UIStackView(arrangedSubviews: [privacyLabel]), padding: 12))
    }

    private func buildSignedInInterface(_ profile: UserProfile) {
        contentStack.addArrangedSubview(makePageTitle("Profile"))

        let avatarLabel = UILabel()
        avatarLabel.text = profile.initials
        avatarLabel.textAlignment = .center
        avatarLabel.font = .systemFont(ofSize: 30, weight: .bold)
        avatarLabel.textColor = .white
        avatarLabel.backgroundColor = CineSeatTheme.primaryText
        avatarLabel.layer.cornerRadius = 44
        avatarLabel.clipsToBounds = true
        avatarLabel.widthAnchor.constraint(equalToConstant: 88).isActive = true
        avatarLabel.heightAnchor.constraint(equalToConstant: 88).isActive = true

        let avatarContainer = UIStackView(arrangedSubviews: [UIView(), avatarLabel, UIView()])
        avatarContainer.axis = .horizontal
        avatarContainer.distribution = .equalCentering
        contentStack.addArrangedSubview(avatarContainer)

        let nameLabel = UILabel()
        nameLabel.text = profile.fullName
        nameLabel.textAlignment = .center
        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        nameLabel.textColor = CineSeatTheme.primaryText
        contentStack.addArrangedSubview(nameLabel)

        let emailLabel = UILabel()
        emailLabel.text = profile.email
        emailLabel.textAlignment = .center
        emailLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        emailLabel.textColor = CineSeatTheme.mutedText
        contentStack.addArrangedSubview(emailLabel)

        let detailsStack = UIStackView()
        detailsStack.axis = .vertical
        detailsStack.addArrangedSubview(CineSeatTheme.captionLabel("Account details"))
        detailsStack.addArrangedSubview(makeInfoRow(label: "Email", value: profile.email))
        detailsStack.addArrangedSubview(makeInfoRow(label: "Phone", value: profile.phoneNumber.isEmpty ? "Not provided" : profile.phoneNumber))
        detailsStack.addArrangedSubview(makeInfoRow(label: "Member since", value: profile.memberSinceText))
        contentStack.addArrangedSubview(makeCard(with: detailsStack))

        let statsStack = UIStackView(arrangedSubviews: [
            makeStat(title: "Confirmed", value: String(viewModel.confirmedBookingsCount)),
            makeStat(title: "All Bookings", value: String(viewModel.totalBookingsCount))
        ])
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.spacing = 10
        contentStack.addArrangedSubview(statsStack)

        let editButton = CineSeatTheme.primaryButton(title: "Edit Profile")
        editButton.accessibilityIdentifier = "editProfileButton"
        editButton.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(editButton)

        let logoutButton = CineSeatTheme.secondaryButton(title: "Log Out")
        logoutButton.accessibilityIdentifier = "logoutButton"
        logoutButton.setTitleColor(.systemRed, for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(logoutButton)
    }

    private func makePageTitle(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = CineSeatTheme.primaryText
        return label
    }

    private func makeStat(title: String, value: String) -> CardView {
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.textAlignment = .center
        valueLabel.font = .monospacedSystemFont(ofSize: 24, weight: .bold)
        valueLabel.textColor = CineSeatTheme.primaryText
        let titleLabel = CineSeatTheme.captionLabel(title)
        titleLabel.textAlignment = .center
        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return makeCard(with: stack, padding: 12)
    }

    // touch up inside action from the storyboard log in button
    @IBAction private func profileLoginButtonTapped(_ sender: UIButton) {
        loginTapped()
    }

    // touch up inside action from the storyboard create account button
    @IBAction private func profileCreateAccountButtonTapped(_ sender: UIButton) {
        createAccountTapped()
    }

    @objc private func loginTapped() {
        navigationController?.pushViewController(factory.makeLoginViewController(), animated: true)
    }

    @objc private func createAccountTapped() {
        navigationController?.pushViewController(factory.makeCreateAccountViewController(), animated: true)
    }

    @objc private func editProfileTapped() {
        let editViewController = factory.makeEditProfileViewController(
            profile: viewModel.currentProfile
        )
        navigationController?.pushViewController(editViewController, animated: true)
    }

    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Log Out?",
            message: "You can sign back in using your email and password.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.viewModel.logOut()
        })
        present(alert, animated: true)
    }
}

// module 2 login screen
// the viewmodel validates before the authentication service signs in
final class LoginViewController: AccountFormViewController {
    var factory = AppFactory.shared
    private lazy var viewModel = factory.makeLoginViewModel()
    private lazy var emailField = makeTextField(
        placeholder: "Email address",
        contentType: .username,
        keyboardType: .emailAddress
    )
    private lazy var passwordField = makeTextField(
        placeholder: "Password",
        contentType: .password,
        isSecure: true
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        emailField.tag = 0
        passwordField.tag = 1
        passwordField.returnKeyType = .go
        emailField.accessibilityIdentifier = "loginEmailField"
        passwordField.accessibilityIdentifier = "loginPasswordField"
        buildInterface()
    }

    private func buildInterface() {
        let heading = UILabel()
        heading.text = "Welcome Back"
        heading.font = .systemFont(ofSize: 24, weight: .bold)
        heading.textColor = CineSeatTheme.primaryText
        contentStack.addArrangedSubview(heading)
        contentStack.addArrangedSubview(CineSeatTheme.captionLabel("Log in to continue to your CineSeat profile."))
        contentStack.addArrangedSubview(makeFormCard(title: "Account", fields: [emailField, passwordField]))

        let loginButton = CineSeatTheme.primaryButton(title: "Log In")
        loginButton.accessibilityIdentifier = "loginSubmitButton"
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(loginButton)

        let createButton = CineSeatTheme.secondaryButton(title: "Create New Account")
        createButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(createButton)
    }

    @objc private func loginTapped() {
        view.endEditing(true)
        do {
            try viewModel.logIn(email: emailField.text ?? "", password: passwordField.text ?? "")
            navigationController?.popToRootViewController(animated: true)
        } catch {
            showError(error)
        }
    }

    @objc private func createAccountTapped() {
        navigationController?.pushViewController(factory.makeCreateAccountViewController(), animated: true)
    }
}

// module 2 create account screen
// account creation checks email password and duplicates before saving
final class CreateAccountViewController: AccountFormViewController {
    var factory = AppFactory.shared
    private lazy var viewModel = factory.makeCreateAccountViewModel()
    private lazy var nameField = makeTextField(placeholder: "Full name", contentType: .name)
    private lazy var emailField = makeTextField(
        placeholder: "Email address",
        contentType: .username,
        keyboardType: .emailAddress
    )
    private lazy var phoneField = makeTextField(
        placeholder: "Phone number (optional)",
        contentType: .telephoneNumber,
        keyboardType: .phonePad
    )
    private lazy var passwordField = makeTextField(
        placeholder: "Password",
        contentType: .newPassword,
        isSecure: true
    )
    private lazy var confirmPasswordField = makeTextField(
        placeholder: "Confirm password",
        contentType: .newPassword,
        isSecure: true
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        let fields = [nameField, emailField, phoneField, passwordField, confirmPasswordField]
        for (index, field) in fields.enumerated() { field.tag = index }
        confirmPasswordField.returnKeyType = .go
        nameField.accessibilityIdentifier = "createNameField"
        emailField.accessibilityIdentifier = "createEmailField"
        phoneField.accessibilityIdentifier = "createPhoneField"
        passwordField.accessibilityIdentifier = "createPasswordField"
        confirmPasswordField.accessibilityIdentifier = "createConfirmPasswordField"
        buildInterface(fields: fields)
    }

    private func buildInterface(fields: [UITextField]) {
        let heading = UILabel()
        heading.text = "Create Your Profile"
        heading.font = .systemFont(ofSize: 24, weight: .bold)
        heading.textColor = CineSeatTheme.primaryText
        contentStack.addArrangedSubview(heading)
        contentStack.addArrangedSubview(CineSeatTheme.captionLabel("Use a password with at least 8 characters, uppercase, lowercase, and one number."))
        contentStack.addArrangedSubview(makeFormCard(title: "Personal information", fields: fields))

        let createButton = CineSeatTheme.primaryButton(title: "Create Account")
        createButton.accessibilityIdentifier = "createAccountSubmitButton"
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(createButton)

        let termsLabel = CineSeatTheme.captionLabel("By creating an account, you agree to keep this profile on this device.")
        termsLabel.textAlignment = .center
        contentStack.addArrangedSubview(termsLabel)
    }

    @objc private func createTapped() {
        view.endEditing(true)
        do {
            try viewModel.createAccount(
                fullName: nameField.text ?? "",
                email: emailField.text ?? "",
                phoneNumber: phoneField.text ?? "",
                password: passwordField.text ?? "",
                confirmPassword: confirmPasswordField.text ?? ""
            )
            navigationController?.popToRootViewController(animated: true)
        } catch {
            showError(error)
        }
    }
}

final class EditProfileViewController: AccountFormViewController {
    var profile: UserProfile?
    var factory = AppFactory.shared
    private lazy var viewModel = factory.makeProfileViewModel()
    private lazy var nameField = makeTextField(placeholder: "Full name", contentType: .name)
    private lazy var emailField = makeTextField(
        placeholder: "Email address",
        contentType: .emailAddress,
        keyboardType: .emailAddress
    )
    private lazy var phoneField = makeTextField(
        placeholder: "Phone number (optional)",
        contentType: .telephoneNumber,
        keyboardType: .phonePad
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Profile"
        nameField.text = profile?.fullName
        emailField.text = profile?.email
        phoneField.text = profile?.phoneNumber
        nameField.tag = 0
        emailField.tag = 1
        phoneField.tag = 2
        phoneField.returnKeyType = .done
        buildInterface()
    }

    private func buildInterface() {
        contentStack.addArrangedSubview(makeFormCard(
            title: "Profile details",
            fields: [nameField, emailField, phoneField]
        ))

        let saveButton = CineSeatTheme.primaryButton(title: "Save Changes")
        saveButton.accessibilityIdentifier = "saveProfileButton"
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(saveButton)
    }

    @objc private func saveTapped() {
        view.endEditing(true)
        do {
            try viewModel.updateProfile(
                fullName: nameField.text ?? "",
                email: emailField.text ?? "",
                phoneNumber: phoneField.text ?? ""
            )
            navigationController?.popViewController(animated: true)
        } catch {
            showError(error)
        }
    }
}

private extension UIView {
    var allTextFields: [UITextField] {
        subviews.flatMap { view -> [UITextField] in
            if let textField = view as? UITextField { return [textField] }
            return view.allTextFields
        }
    }
}
