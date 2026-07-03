/// Auth onboarding adım kimlikleri (sabit sıra).
enum AuthOnboardingStepId {
  role,
  managerExperience,
  residentExperience,
  name,
  identifier,
  credentials,
  contact,
  verification,
  invite,
  features,
  complete,
}

enum AuthContactChannel { phone, email }

enum AuthOnboardingFlow { login, register, join, legacyLogin }

enum ManagerType { primary, invited }
