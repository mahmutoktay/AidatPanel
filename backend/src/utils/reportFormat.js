export function formatMoney(amount, currency = "TRY") {
  return `${amount.toFixed(2)} ${currency}`;
}
