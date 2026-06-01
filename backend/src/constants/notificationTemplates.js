/** Bildirim başlık/gövde şablonları — tek kaynak (A12). */

export const TICKET_CREATED_MANAGER = {
  title: "Yeni talep",
  body: (apartmentNumber, ticketTitle) =>
    `Daire ${apartmentNumber}: ${ticketTitle}`,
};

export const TICKET_UPDATE_NOTE = {
  title: "Talebiniz güncellendi",
  body: (preview) => `Yöneticiniz talebinize not ekledi: ${preview}`,
};

export const DUE_PAID_RESIDENT = {
  title: "Aidatınız ödendi",
  body: (month, year) =>
    `${month}/${year} dönemi aidatınız ödendi olarak işaretlendi.`,
};

export const DUE_REMINDER_RESIDENT = {
  title: "Aidat hatırlatması",
  body: (month, year, amount, currency) =>
    `${month}/${year} dönemi aidatınız (${amount} ${currency}) henüz ödenmemiştir.`,
};

export const DEKONT_RECEIVED_MANAGER = {
  title: "Yeni dekont",
  body: (apartmentNumber, filename) =>
    `Daire ${apartmentNumber}: ${filename} yüklendi.`,
};

export const DEKONT_NEEDS_REVIEW_MANAGER = {
  title: "Dekont inceleme",
  body: (apartmentNumber) =>
    `Daire ${apartmentNumber} dekontu inceleme bekliyor.`,
};

export const DEKONT_PAYMENT_APPLIED_RESIDENT = {
  title: "Dekont onaylandı",
  body: (month, year) => `${month}/${year} dönemi dekontunuz onaylandı ve ödeme işlendi.`,
};

export const DEKONT_MATCHED_MANAGER = {
  title: "Dekont eşleşti",
  body: (apartmentNumber) =>
    `Daire ${apartmentNumber} dekontu otomatik kurallarla eşleşti; onay bekleyebilir.`,
};

export const DEKONT_REJECTED_RESIDENT = {
  title: "Dekont reddedildi",
  body: (reason) => reason || "Yöneticiniz dekontunuzu reddetti.",
};
