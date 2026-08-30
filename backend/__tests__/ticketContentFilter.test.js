import { describe, expect, it } from "@jest/globals";
import {
  matchesContentFilter,
  matchesContentFilterCombined,
  preprocessText,
} from "../src/constants/ticketContentFilter.js";

describe("ticketContentFilter", () => {
  it("preprocessText normalizes Turkish characters", () => {
    expect(preprocessText("ŞİĞÖÜÇ")).toBe("si gouc");
  });

  it("matches listed Turkish profanity", () => {
    expect(matchesContentFilter("bu bir amk testi")).toBe(true);
  });

  it("matches English pattern", () => {
    expect(matchesContentFilter("what the fuck")).toBe(true);
  });

  it("does not match clean text", () => {
    expect(matchesContentFilter("Asansör arızası var, lütfen bakım yapın.")).toBe(false);
  });

  it("matchesContentFilterCombined checks any part", () => {
    expect(matchesContentFilterCombined("temiz başlık", "amk açıklama")).toBe(true);
    expect(matchesContentFilterCombined("temiz", "normal")).toBe(false);
  });
});
