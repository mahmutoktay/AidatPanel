/** @type {import('jest').Config} */
export default {
  testEnvironment: "node",
  moduleNameMapper: {
    "^(\\.{1,2}/.*)\\.js$": "$1",
  },
  testMatch: ["**/__tests__/**/*.test.js"],
  verbose: true,
  forceExit: true,
  clearMocks: true,
  resetMocks: true,
  restoreMocks: true,
  coveragePathIgnorePatterns: [
    "/node_modules/",
    "/__tests__/",
  ],
  setupFilesAfterEnv: ["./__tests__/setup.js"],
};
