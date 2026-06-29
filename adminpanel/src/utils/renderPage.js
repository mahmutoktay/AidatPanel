import path from "path";
import { fileURLToPath } from "url";
import ejs from "ejs";
import { adminApi, cookieHeader } from "../services/apiClient.js";
import * as labels from "../utils/enumLabels.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const viewsDir = path.join(__dirname, "../views");

export async function renderPage(res, partial, data) {
  let notifications = data.notifications;
  if (notifications === undefined) {
    const { json } = await adminApi("/notifications", { cookies: cookieHeader(res.req) });
    notifications = json?.data || [];
  }

  const pageData = {
    queryMsg: res.req?.query?.msg,
    queryDetail: res.req?.query?.detail,
    notifications,
    labels,
    ...data,
  };
  const content = await ejs.renderFile(path.join(viewsDir, "partials", `${partial}.ejs`), pageData, {
    views: [path.join(viewsDir, "partials")],
  });
  res.render("pages/layout-page", {
    includeCharts: data.includeCharts ?? false,
    notifications,
    labels,
    ...data,
    content,
  });
}
