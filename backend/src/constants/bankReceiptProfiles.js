import { normalizeIban } from "../utils/iban.js";
import { parseTrAmount } from "../utils/parseTrAmount.js";

const TR_IBAN_INLINE =
  /TR\s*\d{2}(?:\s*\d{4}){0,6}\s*\d{0,4}/gi;

/** pdftotext / OCR satır kırıklıklarını düzelt */
export function preprocessReceiptText(rawText) {
  let text = String(rawText ?? "");
  // VakıfBank: IBAN iki satıra bölünür
  text = text.replace(
    /(TR\s*\d{2}(?:\s*\d{4}){2,4})\s*\n\s*((?:\d{4}\s*){1,3}\d{0,4})/gi,
    (_, head, tail) => `${head} ${tail}`
  );
  text = text.replace(/[ \t]+/g, " ");
  return text;
}

function firstCapture(text, regex) {
  const re = regex.global ? regex : new RegExp(regex.source, regex.flags + "g");
  re.lastIndex = 0;
  const m = re.exec(text);
  if (!m) return null;
  return (m[1] ?? m[0]).trim();
}

function captureIban(text, labelPattern) {
  const m = labelPattern.exec(text);
  if (!m) return null;
  const chunk = m[1].replace(/\s+/g, " ");
  const ibanMatch = chunk.match(/TR\s*\d{2}(?:\s*\d{4}){5}\s*\d{2}/i);
  if (!ibanMatch) return null;
  return normalizeIban(ibanMatch[0]);
}

function parseDateFromText(text) {
  const patterns = [
    /İşlem TARİHİ\s*:\s*(\d{1,2})[./](\d{1,2})[./](\d{4})(?:-\d{2}:\d{2}:\d{2})?/i,
    /İşlem Tarihi\s*:\s*(\d{1,2})[./](\d{1,2})[./](\d{4})/i,
    /İşlem Zam\.\/Valör\s*:\s*(\d{1,2})[./](\d{1,2})[./](\d{4})/i,
    /İŞLEM TARİHİ\s+(\d{1,2})[./](\d{1,2})[./](\d{4})/i,
    /Belge Tarihi\s*:\s*(\d{1,2})-(\d{1,2})-(\d{4})/i,
    /DÜZENLENME TARİHİ\s*:\s*(\d{1,2})[./](\d{1,2})[./](\d{4})/i,
    /Valör\s*:\s*(\d{1,2})[./](\d{1,2})[./](\d{4})/i,
    /VALÖR TARİHİ\s*:\s*(\d{1,2})[./](\d{1,2})[./](\d{4})/i,
    /\b(\d{1,2})[./](\d{1,2})[./](\d{4})\b/,
  ];

  for (const re of patterns) {
    const m = re.exec(text);
    if (!m) continue;
    const dd = String(m[1]).padStart(2, "0");
    const mm = String(m[2]).padStart(2, "0");
    const yyyy = m[3].length === 2 ? `20${m[3]}` : m[3];
    return new Date(`${yyyy}-${mm}-${dd}T12:00:00.000Z`);
  }
  return null;
}

function buildParsed({ bankCode, receiverIban, amount, referenceNumber, transactionDate, receiverName }) {
  return {
    profile: bankCode,
    parsed: {
      bankCode,
      receiverIban: receiverIban ?? null,
      receiverName: receiverName ?? null,
      amount: amount ?? null,
      currency: "TRY",
      transactionDate: transactionDate ? transactionDate.toISOString() : null,
      referenceNumber: referenceNumber ?? null,
    },
  };
}

/**
 * Örnek dekontlar: Dekontlar/ klasörü (2026-05).
 * Her profil detect + alan regex'leri gerçek PDF metninden türetildi.
 */
export const BANK_PROFILES = [
  {
    code: "KUVEYT_TURK",
    detect: /kuveytturk\.com|Kuveyt Türk Katılım Bankası/i,
    parse(text) {
      const receiverIban =
        captureIban(text, /Alıcı IBAN\s*:\s*(TR[\d\s]+)/i) ??
        captureIban(text, /Alınan IBAN\s*:\s*(TR[\d\s]+)/i);
      const amount = parseTrAmount(
        firstCapture(text, /Tutar\s*:\s*([0-9.,\s]+)\s*TL/i)
      );
      const referenceNumber =
        firstCapture(text, /Belge No\s*:\s*([A-Z0-9-]+)/i) ??
        firstCapture(text, /İşlem Ref\s*:\s*([A-Z0-9-]+)/i);
      const receiverName = firstCapture(text, /Alıcı\s*:\s*([^\n]+)/i);
      return buildParsed({
        bankCode: "KUVEYT_TURK",
        receiverIban,
        amount,
        referenceNumber,
        transactionDate: parseDateFromText(text),
        receiverName,
      });
    },
  },
  {
    code: "ZIRAAT",
    detect: /T\.?\s*C\.?\s*ZİRAAT|T\.?\s*C\.?\s*Ziraat|ziraatbank\.com/i,
    parse(text) {
      const receiverIban = captureIban(
        text,
        /Alıcı Hesap\s*:\s*(TR[\d\s]+(?:Alıcı|$))/i
      );
      const amount = parseTrAmount(
        firstCapture(text, /İşlem Tutarı\s*:\s*([0-9.,\s]+)\s*TRY/i)
      );
      const referenceNumber =
        firstCapture(text, /Fast Sorgu No\s*:\s*(\d{8,16})/i) ??
        firstCapture(text, /Sorgu No\s*:\s*(\d{8,16})/i);
      const receiverName = firstCapture(text, /Alıcı\s*:\s*([^\n]+?)(?:\s*İşlem Tutarı|$)/i);
      return buildParsed({
        bankCode: "ZIRAAT",
        receiverIban,
        amount,
        referenceNumber,
        transactionDate: parseDateFromText(text),
        receiverName,
      });
    },
  },
  {
    code: "ISBANK",
    detect: /www\.isbank\.com\.tr|İş\s*Bankası|İşCep/i,
    parse(text) {
      const receiverIban = captureIban(text, /Alıcı IBAN\s*:\s*(TR[\d\s]+)/i);
      const amount = parseTrAmount(
        firstCapture(text, /İşlem Tutarı\s*:\s*([0-9.,\s]+)\s*TRY/i)
      );
      const referenceNumber = firstCapture(
        text,
        /Sorgu Numarası\s*:\s*(\d{8,16})/i
      );
      const receiverName = firstCapture(text, /Alıcı Isim\\Unvan\s*:\s*([^\n]+)/i);
      return buildParsed({
        bankCode: "ISBANK",
        receiverIban,
        amount,
        referenceNumber,
        transactionDate: parseDateFromText(text),
        receiverName,
      });
    },
  },
  {
    code: "GARANTI",
    detect: /Garanti Bankası A\.Ş\.|Garanti BBVA|garantibbva\.com/i,
    parse(text) {
      const receiverIban = captureIban(
        text,
        /ALACAKLI IBAN\s*:\s*(TR[\d\s]+)/i
      );
      const amount = parseTrAmount(
        firstCapture(text, /TUTAR\s*:\s*-?\s*([0-9.,\s]+)\s*TL/i) ??
          firstCapture(text, /TUTAR\s*:\s*-?\s*([0-9.,\s]+)/i)
      );
      const referenceNumber =
        firstCapture(text, /FAST REF NO\s*:\s*(\d{8,16})/i) ??
        firstCapture(text, /SIRA NO\s*:\s*([\d.-]+)/i);
      const receiverName = firstCapture(text, /ALACAKLI\s*:\s*([^\n]+)/i);
      return buildParsed({
        bankCode: "GARANTI",
        receiverIban,
        amount,
        referenceNumber,
        transactionDate: parseDateFromText(text),
        receiverName,
      });
    },
  },
  {
    code: "HALKBANK",
    detect: /halkbank\.com\.tr|Halkbank|HALKBANK/i,
    parse(text) {
      const receiverIban = captureIban(text, /ALICI IBAN\s*:\s*(TR[\d\s]+)/i);
      const amount = parseTrAmount(
        firstCapture(text, /İŞLEM TUTARI\s*\(TL\)\s*:\s*([0-9.,\s]+)/i) ??
          firstCapture(text, /TOPLAM\s*\(TL\s*\)\s*:\s*([0-9.,\s]+)/i)
      );
      const referenceNumber = firstCapture(text, /SORGU NO\s*:\s*(\d{6,16})/i);
      const receiverName = firstCapture(text, /ALICI\s*:\s*([^\n]+)/i);
      return buildParsed({
        bankCode: "HALKBANK",
        receiverIban,
        amount,
        referenceNumber,
        transactionDate: parseDateFromText(text),
        receiverName,
      });
    },
  },
  {
    code: "VAKIFBANK",
    detect: /vakifbank\.com\.tr|VAKIFBANK|Türkiye Vakıflar Bankası/i,
    parse(text) {
      let receiverIban = captureIban(
        text,
        /ALICI HESAP NO\s*\/\s*(TR[\d\s]+)/i
      );
      if (!receiverIban || receiverIban.length < 26) {
        const head = firstCapture(text, /ALICI HESAP NO\s*\/\s*(TR[\d\s]+)/i);
        const tail = firstCapture(text, /IBAN\s+([\d\s]{6,20})/i);
        if (head && tail) {
          receiverIban = normalizeIban(`${head} ${tail}`);
        }
      }
      const amount = parseTrAmount(
        firstCapture(text, /İŞLEM TUTARI\s+([0-9.,\s]+)\s*TL/i)
      );
      const referenceNumber = firstCapture(text, /SORGU NO\s+(\d{8,16})/i);
      const receiverName = firstCapture(
        text,
        /ALICI AD\s+([^\n]+?)\s+SOYAD\/UNVAN/i
      );
      return buildParsed({
        bankCode: "VAKIFBANK",
        receiverIban,
        amount,
        referenceNumber,
        transactionDate: parseDateFromText(text),
        receiverName,
      });
    },
  },
  {
    code: "YKB",
    detect: /yapikredi\.com|Yapı\s*Kredi|YKB/i,
    parse(text) {
      const receiverIban = captureIban(
        text,
        /Alıcı IBAN\s*(?:No)?\s*:\s*(TR[\d\s]+)/i
      );
      const amount = parseTrAmount(
        firstCapture(text, /(?:Transfer Tutarı|İşlem Tutarı)\s*:\s*([0-9.,\s]+)\s*(?:TL|TRY)?/i)
      );
      const referenceNumber = firstCapture(
        text,
        /(?:Sorgu|Referans)\s*(?:Numarası|No)?\s*:\s*(\d{6,16})/i
      );
      const receiverName = firstCapture(text, /Alıcı(?:\s*Adı)?\s*:\s*([^\n]+)/i);
      return buildParsed({
        bankCode: "YKB",
        receiverIban,
        amount,
        referenceNumber,
        transactionDate: parseDateFromText(text),
        receiverName,
      });
    },
  },
  {
    code: "AKBANK",
    detect: /akbank\.com|Akbank/i,
    parse(text) {
      const receiverIban = captureIban(
        text,
        /(?:Alıcı|Lehtar) IBAN\s*:\s*(TR[\d\s]+)/i
      );
      const amount = parseTrAmount(
        firstCapture(text, /(?:İşlem Tutarı|Tutar)\s*:\s*([0-9.,\s]+)\s*(?:TL|TRY)?/i)
      );
      const referenceNumber = firstCapture(
        text,
        /(?:Sorgu Numarası|Referans(?:\s*No)?)\s*:\s*(\d{6,16})/i
      );
      const receiverName = firstCapture(text, /(?:Alıcı|Lehtar)\s*:\s*([^\n]+)/i);
      return buildParsed({
        bankCode: "AKBANK",
        receiverIban,
        amount,
        referenceNumber,
        transactionDate: parseDateFromText(text),
        receiverName,
      });
    },
  },
  {
    code: "QNB",
    detect: /qnb\.com|QNB|Finansbank|Enpara/i,
    parse(text) {
      const receiverIban = captureIban(
        text,
        /(?:Alıcı|Lehtar) IBAN\s*:\s*(TR[\d\s]+)/i
      );
      const amount = parseTrAmount(
        firstCapture(text, /(?:İşlem Tutarı|Tutar)\s*:\s*([0-9.,\s]+)\s*(?:TL|TRY)?/i)
      );
      const referenceNumber = firstCapture(
        text,
        /(?:Referans|Sorgu)(?:\s*No|\s*Numarası)?\s*:\s*(\d{6,16})/i
      );
      const receiverName = firstCapture(text, /(?:Alıcı|Lehtar)\s*:\s*([^\n]+)/i);
      return buildParsed({
        bankCode: "QNB",
        receiverIban,
        amount,
        referenceNumber,
        transactionDate: parseDateFromText(text),
        receiverName,
      });
    },
  },
];

function parseGenericTr(text) {
  const ibans = [...text.matchAll(TR_IBAN_INLINE)].map((m) => normalizeIban(m[0]));
  const receiverIban =
    captureIban(text, /(?:Alıcı|ALACAKLI|Lehtar)(?:\s*IBAN|\s*Hesap)?\s*:\s*(TR[\d\s]+)/i) ??
    ibans[ibans.length - 1] ??
    ibans[0] ??
    null;

  const amount = parseTrAmount(
    firstCapture(text, /(?:İşlem Tutarı|İŞLEM TUTARI|Tutar|TUTAR)\s*[:(]?\s*([0-9.,\s]+)/i)
  );
  const referenceNumber = firstCapture(
    text,
    /(?:Sorgu|Referans|FAST REF)(?:\s*No|\s*Numarası)?\s*:\s*(\d{6,16})/i
  );

  return buildParsed({
    bankCode: "GENERIC_TR",
    receiverIban,
    amount,
    referenceNumber,
    transactionDate: parseDateFromText(text),
    receiverName: null,
  });
}

export function parseReceiptText(rawText) {
  const text = preprocessReceiptText(rawText);
  const profile = BANK_PROFILES.find((p) => p.detect.test(text));
  if (profile) {
    return profile.parse(text);
  }
  return parseGenericTr(text);
}
