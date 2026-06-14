/** Bildirim başlık/gövde şablonları — tek kaynak (A12). */

export const TICKET_CREATED_MANAGER = {
  title: "Yeni Destek Talebi",
  body: (apartmentNumber, ticketTitle) =>
    `Daire ${apartmentNumber} yeni bir talep oluşturdu: "${ticketTitle}"`,
};

export const TICKET_UPDATE_NOTE = {
  title: "Talebinize Yanıt Geldi",
  body: (preview) => `Yöneticiniz talebinize bir not ekledi: "${preview}"`,
};

export const DUE_PAID_RESIDENT = {
  title: "Ödemeniz Başarıyla İşlendi ✓",
  body: (month, year) =>
    `${month}/${year} dönemi aidat ödemeniz başarıyla hesabınıza işlenmiştir.`,
};

export const DUE_REMINDER_RESIDENT = {
  title: "Aidat Ödeme Hatırlatması",
  body: (month, year, amount, currency) =>
    `${month}/${year} dönemi aidat tutarınız (${amount} ${currency}) henüz ödenmemiştir. Lütfen ödemenizi gerçekleştiriniz.`,
};

export const DEKONT_RECEIVED_MANAGER = {
  title: "Yeni Ödeme Bildirimi",
  body: (apartmentNumber, filename) =>
    `Daire ${apartmentNumber} tarafından yeni bir ödeme dekontu (${filename}) sisteme yüklendi.`,
};

export const DEKONT_NEEDS_REVIEW_MANAGER = {
  title: "Dekont İnceleme Bekliyor",
  body: (apartmentNumber) =>
    `Daire ${apartmentNumber} tarafından yüklenen dekont incelemenizi bekliyor.`,
};

export const DEKONT_PAYMENT_APPLIED_RESIDENT = {
  title: "Ödemeniz Onaylandı ✓",
  body: (month, year) => `${month}/${year} dönemine ait aidat ödemeniz yöneticiniz tarafından onaylanmış ve hesabınıza işlenmiştir.`,
};

export const DEKONT_MATCHED_MANAGER = {
  title: "Dekont Otomatik Eşleştirildi",
  body: (apartmentNumber) =>
    `Daire ${apartmentNumber} dekontu sistem tarafından otomatik olarak eşleştirildi. Onayınızı bekliyor.`,
};

export const DEKONT_REJECTED_RESIDENT = {
  title: "Dekontunuz Reddedildi",
  body: (reason) => reason
    ? `Yöneticiniz dekontunuzu şu gerekçeyle reddetti: "${reason}". Lütfen düzeltip tekrar yükleyiniz.`
    : "Yöneticiniz dekontunuzu reddetti. Detaylar için uygulama içinden inceleyebilirsiniz.",
};

export const EXPENSE_ADDED_RESIDENT = {
  title: "Yeni Gider Eklendi",
  body: ({ title, month, year, amountStr, categoryLabel, splitMonths }) => {
    const period = `${month}/${year}`;
    if (splitMonths > 1) {
      return `Yöneticiniz "${title}" (${categoryLabel}) giderini ${splitMonths} aya böldü. Aidat tutarınız güncellenecektir.`;
    }
    if (amountStr) {
      return `Yöneticiniz ${period} dönemine "${title}" (${categoryLabel}, ${amountStr}) giderini ekledi. Aidat tutarınız güncellendi.`;
    }
    return `Yöneticiniz ${period} dönemine "${title}" (${categoryLabel}) giderini ekledi. Tutar belirlenince aidatınız güncellenecek.`;
  },
};
