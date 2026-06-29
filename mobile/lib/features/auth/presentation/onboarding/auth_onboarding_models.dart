/// Auth onboarding adım kimlikleri (sabit sıra).
enum AuthOnboardingStepId {
  role,
  contact,
  verification,
  invite,
  features,
  complete,
}

enum AuthContactChannel { phone, email }

enum AuthOnboardingFlow { login, register, join, legacyLogin }

enum ManagerType { primary, invited }
