export const NOTIFICATION_CODES = Object.freeze({
  TICKET_CREATED_MANAGER: "ticket_created_manager",
  TICKET_UPDATE_NOTE: "ticket_update_note",
  TICKET_STATUS_IN_PROGRESS: "ticket_status_in_progress",
  TICKET_STATUS_RESOLVED: "ticket_status_resolved",
  TICKET_STATUS_CLOSED: "ticket_status_closed",
  DUE_PAID_RESIDENT: "due_paid_resident",
  DUE_REMINDER_RESIDENT: "due_reminder_resident",
  DEKONT_RECEIVED_MANAGER: "dekont_received_manager",
  DEKONT_NEEDS_REVIEW_MANAGER: "dekont_needs_review_manager",
  DEKONT_PAYMENT_APPLIED_RESIDENT: "dekont_payment_applied_resident",
  DEKONT_MATCHED_MANAGER: "dekont_matched_manager",
  DEKONT_REJECTED_RESIDENT: "dekont_rejected_resident",
  EXPENSE_ADDED_RESIDENT: "expense_added_resident",
  DEV_SEED: "dev_seed",
  ANNOUNCEMENT_CUSTOM: "announcement_custom",
  LEGACY_NOTIFICATION: "legacy_notification",
});

const text = (params, key, fallback = "") => {
  const value = params?.[key];
  if (value === null || value === undefined) return fallback;
  const normalized = String(value).trim();
  return normalized || fallback;
};

const period = (params) => `${text(params, "month", "?")}/${text(params, "year", "?")}`;

export const NOTIFICATION_CATALOG = Object.freeze({
  [NOTIFICATION_CODES.TICKET_CREATED_MANAGER]: Object.freeze({
    tr: Object.freeze({
      title: () => "Yeni Destek Talebi",
      body: (params) =>
        `Daire ${text(params, "apartmentNumber", "?")} yeni bir talep oluşturdu: "${text(params, "ticketTitle", "Talep" )}"`,
    }),
    en: Object.freeze({
      title: () => "New Support Request",
      body: (params) =>
        `Apartment ${text(params, "apartmentNumber", "?")} created a new request: "${text(params, "ticketTitle", "Request")}"`,
    }),
  }),

  [NOTIFICATION_CODES.TICKET_UPDATE_NOTE]: Object.freeze({
    tr: Object.freeze({
      title: () => "Talebinize Yanıt Geldi",
      body: (params) => `Yöneticiniz talebinize bir not ekledi: "${text(params, "preview", "")}"`,
    }),
    en: Object.freeze({
      title: () => "Your Request Has a Response",
      body: (params) => `Your manager added a note to your request: "${text(params, "preview", "")}"`,
    }),
  }),

  [NOTIFICATION_CODES.TICKET_STATUS_IN_PROGRESS]: Object.freeze({
    tr: Object.freeze({
      title: () => "Talebiniz inceleniyor",
      body: (params) => `"${text(params, "ticketTitle", "Talep")}" talebiniz üzerinde çalışılıyor.`,
    }),
    en: Object.freeze({
      title: () => "Your Request Is Being Reviewed",
      body: (params) => `Your request "${text(params, "ticketTitle", "Request")}" is being worked on.`,
    }),
  }),

  [NOTIFICATION_CODES.TICKET_STATUS_RESOLVED]: Object.freeze({
    tr: Object.freeze({
      title: () => "Talebiniz çözüldü",
      body: (params) => `"${text(params, "ticketTitle", "Talep")}" talebiniz çözüldü olarak işaretlendi.`,
    }),
    en: Object.freeze({
      title: () => "Your Request Was Resolved",
      body: (params) => `Your request "${text(params, "ticketTitle", "Request")}" was marked as resolved.`,
    }),
  }),

  [NOTIFICATION_CODES.TICKET_STATUS_CLOSED]: Object.freeze({
    tr: Object.freeze({
      title: () => "Talebiniz kapatıldı",
      body: (params) => `"${text(params, "ticketTitle", "Talep")}" talebiniz kapatıldı.`,
    }),
    en: Object.freeze({
      title: () => "Your Request Was Closed",
      body: (params) => `Your request "${text(params, "ticketTitle", "Request")}" was closed.`,
    }),
  }),

  [NOTIFICATION_CODES.DUE_PAID_RESIDENT]: Object.freeze({
    tr: Object.freeze({
      title: () => "Ödemeniz Başarıyla İşlendi ✓",
      body: (params) => `${period(params)} dönemi aidat ödemeniz başarıyla hesabınıza işlenmiştir.`,
    }),
    en: Object.freeze({
      title: () => "Payment Processed Successfully ✓",
      body: (params) => `Your due payment for ${period(params)} has been successfully credited to your account.`,
    }),
  }),

  [NOTIFICATION_CODES.DUE_REMINDER_RESIDENT]: Object.freeze({
    tr: Object.freeze({
      title: () => "Aidat Ödeme Hatırlatması",
      body: (params) =>
        `${period(params)} dönemi aidat tutarınız (${text(params, "amount", "0.00")} ${text(params, "currency", "TRY")}) henüz ödenmemiştir. Lütfen ödemenizi gerçekleştiriniz.`,
    }),
    en: Object.freeze({
      title: () => "Due Payment Reminder",
      body: (params) =>
        `Your due amount for ${period(params)} (${text(params, "amount", "0.00")} ${text(params, "currency", "TRY")}) has not been paid yet. Please proceed with your payment.`,
    }),
  }),

  [NOTIFICATION_CODES.DEKONT_RECEIVED_MANAGER]: Object.freeze({
    tr: Object.freeze({
      title: () => "Yeni Ödeme Bildirimi",
      body: (params) =>
        `Daire ${text(params, "apartmentNumber", "?")} tarafından yeni bir ödeme dekontu (${text(params, "filename", "dosya")}) sisteme yüklendi.`,
    }),
    en: Object.freeze({
      title: () => "New Payment Receipt",
      body: (params) =>
        `Apartment ${text(params, "apartmentNumber", "?")} uploaded a new payment receipt (${text(params, "filename", "file")}) to the system.`,
    }),
  }),

  [NOTIFICATION_CODES.DEKONT_NEEDS_REVIEW_MANAGER]: Object.freeze({
    tr: Object.freeze({
      title: () => "Dekont İnceleme Bekliyor",
      body: (params) =>
        `Daire ${text(params, "apartmentNumber", "?")} tarafından yüklenen dekont incelemenizi bekliyor.`,
    }),
    en: Object.freeze({
      title: () => "Receipt Pending Review",
      body: (params) =>
        `The receipt uploaded by Apartment ${text(params, "apartmentNumber", "?")} is pending your review.`,
    }),
  }),

  [NOTIFICATION_CODES.DEKONT_PAYMENT_APPLIED_RESIDENT]: Object.freeze({
    tr: Object.freeze({
      title: () => "Ödemeniz Onaylandı ✓",
      body: (params) =>
        `${period(params)} dönemine ait aidat ödemeniz yöneticiniz tarafından onaylanmış ve hesabınıza işlenmiştir.`,
    }),
    en: Object.freeze({
      title: () => "Payment Approved ✓",
      body: (params) =>
        `Your due payment for ${period(params)} has been approved by your manager and credited to your account.`,
    }),
  }),

  [NOTIFICATION_CODES.DEKONT_MATCHED_MANAGER]: Object.freeze({
    tr: Object.freeze({
      title: () => "Dekont Otomatik Eşleştirildi",
      body: (params) =>
        `Daire ${text(params, "apartmentNumber", "?")} dekontu sistem tarafından otomatik olarak eşleştirildi. Onayınızı bekliyor.`,
    }),
    en: Object.freeze({
      title: () => "Receipt Auto-Matched",
      body: (params) =>
        `Apartment ${text(params, "apartmentNumber", "?")}'s receipt has been automatically matched by the system. Awaiting your approval.`,
    }),
  }),

  [NOTIFICATION_CODES.DEKONT_REJECTED_RESIDENT]: Object.freeze({
    tr: Object.freeze({
      title: () => "Dekontunuz Reddedildi",
      body: (params) => {
        const reason = text(params, "reason", "");
        return reason
          ? `Yöneticiniz dekontunuzu şu gerekçeyle reddetti: "${reason}". Lütfen düzeltip tekrar yükleyiniz.`
          : "Yöneticiniz dekontunuzu reddetti. Detaylar için uygulama içinden inceleyebilirsiniz.";
      },
    }),
    en: Object.freeze({
      title: () => "Your Receipt Was Rejected",
      body: (params) => {
        const reason = text(params, "reason", "");
        return reason
          ? `Your manager rejected your receipt with the following reason: "${reason}". Please correct and re-upload.`
          : "Your manager rejected your receipt. You can review the details in the app.";
      },
    }),
  }),

  [NOTIFICATION_CODES.EXPENSE_ADDED_RESIDENT]: Object.freeze({
    tr: Object.freeze({
      title: () => "Yeni Gider Eklendi",
      body: (params) => {
        const splitMonths = Number(text(params, "splitMonths", "1"));
        const title = text(params, "title", "Gider");
        const categoryLabel = text(params, "categoryLabel", "Kategori");
        const amountStr = text(params, "amountStr", "");
        if (splitMonths > 1) {
          return `Yöneticiniz "${title}" (${categoryLabel}) giderini ${splitMonths} aya böldü. Aidat tutarınız güncellenecektir.`;
        }
        if (amountStr) {
          return `Yöneticiniz ${period(params)} dönemine "${title}" (${categoryLabel}, ${amountStr}) giderini ekledi. Aidat tutarınız güncellendi.`;
        }
        return `Yöneticiniz ${period(params)} dönemine "${title}" (${categoryLabel}) giderini ekledi. Tutar belirlenince aidatınız güncellenecek.`;
      },
    }),
    en: Object.freeze({
      title: () => "New Expense Added",
      body: (params) => {
        const splitMonths = Number(text(params, "splitMonths", "1"));
        const title = text(params, "title", "Expense");
        const categoryLabel = text(params, "categoryLabel", "Category");
        const amountStr = text(params, "amountStr", "");
        if (splitMonths > 1) {
          return `Your manager split the expense "${title}" (${categoryLabel}) across ${splitMonths} months. Your due amount will be updated.`;
        }
        if (amountStr) {
          return `Your manager added "${title}" (${categoryLabel}, ${amountStr}) to the ${period(params)} period. Your due amount has been updated.`;
        }
        return `Your manager added "${title}" (${categoryLabel}) to the ${period(params)} period. Your due will be updated once the amount is set.`;
      },
    }),
  }),

  [NOTIFICATION_CODES.DEV_SEED]: Object.freeze({
    tr: Object.freeze({
      title: () => "AidatPanel Test Bildirimi",
      body: () => "Bildirim modülü çalışıyor — Postman veya mobil uygulama ile doğrulayabilirsiniz.",
    }),
    en: Object.freeze({
      title: () => "AidatPanel Test Notification",
      body: () => "Notification system is operational — verify via Postman or mobile app.",
    }),
  }),

  [NOTIFICATION_CODES.ANNOUNCEMENT_CUSTOM]: Object.freeze({
    tr: Object.freeze({
      title: (params) => text(params, "title", "Duyuru"),
      body: (params) => text(params, "body", ""),
    }),
    en: Object.freeze({
      title: (params) => text(params, "title", "Announcement"),
      body: (params) => text(params, "body", ""),
    }),
  }),

  [NOTIFICATION_CODES.LEGACY_NOTIFICATION]: Object.freeze({
    tr: Object.freeze({
      title: (params) => text(params, "title", "Bildirim"),
      body: (params) => text(params, "body", ""),
    }),
    en: Object.freeze({
      title: (params) => text(params, "title", "Notification"),
      body: (params) => text(params, "body", ""),
    }),
  }),
});
