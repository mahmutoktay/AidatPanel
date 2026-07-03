const API_BASE = (process.env.ADMIN_API_BASE || "http://localhost:4200/api/v1/admin").replace(/\/$/, "");

export async function adminApi(path, { method = "GET", body, cookies, query } = {}) {
  const url = new URL(`${API_BASE}${path}`);
  if (query) {
    for (const [k, v] of Object.entries(query)) {
      if (v !== undefined && v !== null && v !== "") url.searchParams.set(k, v);
    }
  }

  const headers = { Accept: "application/json" };
  if (body) headers["Content-Type"] = "application/json";
  if (cookies) headers.Cookie = cookies;

  try {
    const res = await fetch(url, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined,
    });

    const json = await res.json().catch(() => ({}));
    return { status: res.status, ok: res.ok, json, headers: res.headers };
  } catch (err) {
    return {
      status: 0,
      ok: false,
      json: {
        success: false,
        message: `API bağlantı hatası: ${err.message}. Backend adresi: ${API_BASE}`,
      },
      fetchError: true,
    };
  }
}

export function cookieHeader(req) {
  const parts = [];
  if (req.cookies?.admin_token) parts.push(`admin_token=${req.cookies.admin_token}`);
  if (req.cookies?.admin_refresh) parts.push(`admin_refresh=${req.cookies.admin_refresh}`);
  return parts.join("; ");
}

export { API_BASE };
