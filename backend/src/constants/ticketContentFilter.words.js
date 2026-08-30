/**
 * Uygunsuz içerik kelime/regex listesi — Play Store içerik derecelendirmesi denetimi.
 * Yalnızca admin incelemesi için sessiz bayraklama; kullanıcıya gösterilmez.
 */
export const TICKET_FILTER_WORDS = [
  // Küfür / hakaret (örnek liste — genişletilebilir)
  "amk",
  "aq",
  "orospu",
  "piç",
  "siktir",
  "sikeyim",
  "göt",
  "yarrak",
  "kahpe",
  "pezevenk",
];

export const TICKET_FILTER_PATTERNS = [
  /\b(fuck|shit|bitch|asshole)\b/i,
];
