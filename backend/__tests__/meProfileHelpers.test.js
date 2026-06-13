import {
  buildPaymentReference,
  resolveContactValues,
} from "../src/services/me/profileHelpers.js";
import { HttpError } from "../src/utils/httpError.js";
import { formatMoney } from "../src/utils/reportFormat.js";

describe("me profileHelpers", () => {
  test("buildPaymentReference template degiskeni", () => {
    expect(buildPaymentReference("Daire {{number}} aidat", "12")).toBe(
      "Daire 12 aidat"
    );
    expect(buildPaymentReference(null, "5")).toBeNull();
    expect(buildPaymentReference("", "5")).toBeNull();
  });

  test("resolveContactValues degisim tespiti", () => {
    const user = { email: "a@b.com", phone: "+905551112233" };
    const same = resolveContactValues(user, {});
    expect(same.isEmailChanged).toBe(false);
    expect(same.isPhoneChanged).toBe(false);
    expect(same.newEmail).toBe("a@b.com");

    const changed = resolveContactValues(user, { email: "c@d.com" });
    expect(changed.isEmailChanged).toBe(true);
    expect(changed.newEmail).toBe("c@d.com");
  });
});

describe("reportFormat", () => {
  test("formatMoney TRY", () => {
    expect(formatMoney(1250.5)).toBe("1250.50 TRY");
    expect(formatMoney(0, "USD")).toBe("0.00 USD");
  });
});

describe("HttpError", () => {
  test("status ve data", () => {
    const err = new HttpError(409, "Çakışma", { code: "DUPLICATE" });
    expect(err.statusCode).toBe(409);
    expect(err.message).toBe("Çakışma");
    expect(err.data).toEqual({ code: "DUPLICATE" });
  });
});
