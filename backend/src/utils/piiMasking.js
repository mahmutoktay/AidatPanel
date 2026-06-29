/**
 * PII maskeleme — listelerde minimum veri ilkesi.
 */
export function maskEmail(email) {
  if (!email) return "—";
  const [local, domain] = email.split("@");
  if (!domain) return "***";
  const visible = local.length <= 1 ? "*" : local[0];
  return `${visible}***@${domain}`;
}

export function maskPhone(phone) {
  if (!phone) return "—";
  if (phone.length <= 4) return "****";
  return `${phone.slice(0, 3)}***${phone.slice(-2)}`;
}

export function maskName(name) {
  if (!name) return "—";
  const parts = name.trim().split(/\s+/);
  if (parts.length === 1) {
    return parts[0].length <= 2 ? `${parts[0][0]}***` : `${parts[0][0]}***`;
  }
  return `${parts[0]} ${parts[parts.length - 1][0]}.`;
}
