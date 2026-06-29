import { spawn } from "node:child_process";
import crypto from "node:crypto";
import { createWriteStream } from "node:fs";
import { existsSync } from "node:fs";
import { mkdir, stat } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { createGzip } from "node:zlib";
import { pipeline } from "node:stream/promises";
import { prisma } from "../../config/db.js";
import { HttpError } from "../../utils/httpError.js";
import { writeAdminAuditLog } from "./adminAuditService.js";
import { logger } from "../../config/logger.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const backendRoot = path.resolve(__dirname, "../../..");

function getBackupDir() {
  if (process.env.ADMIN_BACKUP_DIR) return process.env.ADMIN_BACKUP_DIR;
  return path.join(backendRoot, "backups", "admin");
}

function resolvePgDumpBinary() {
  if (process.env.PG_DUMP_PATH && existsSync(process.env.PG_DUMP_PATH)) {
    return process.env.PG_DUMP_PATH;
  }
  if (process.platform === "win32") {
    for (const ver of ["17", "16", "15", "14", "13"]) {
      const candidate = `C:\\Program Files\\PostgreSQL\\${ver}\\bin\\pg_dump.exe`;
      if (existsSync(candidate)) return candidate;
    }
  }
  return "pg_dump";
}

function serializeBackup(row) {
  return {
    ...row,
    sizeBytes: row.sizeBytes != null ? Number(row.sizeBytes) : null,
  };
}

function parseDatabaseUrl() {
  const url = process.env.DATABASE_URL;
  if (!url) throw new HttpError(500, "DATABASE_URL tanımlı değil.");
  return url;
}

export async function createBackupService(adminId, ipAddress) {
  const backupDir = getBackupDir();
  await mkdir(backupDir, { recursive: true });

  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  const filename = `aidatpanel-${timestamp}.sql.gz`;
  const filepath = path.join(backupDir, filename);

  const record = await prisma.dbBackup.create({
    data: {
      filename,
      status: "PENDING",
      createdById: adminId,
    },
  });

  await writeAdminAuditLog({
    adminId,
    action: "BACKUP_CREATE",
    targetType: "DbBackup",
    targetId: record.id,
    ipAddress,
  });

  runPgDump(filepath, record.id).catch(async (err) => {
    await prisma.dbBackup.update({
      where: { id: record.id },
      data: { status: "FAILED", errorMessage: err.message },
    });
  });

  return serializeBackup(record);
}

function runPgDump(filepath, backupId) {
  return new Promise((resolve, reject) => {
    const pgDumpBin = resolvePgDumpBinary();
    const dbUrl = parseDatabaseUrl();
    const args = ["--dbname", dbUrl, "--no-owner", "--no-acl"];

    const pgDump = spawn(pgDumpBin, args, {
      stdio: ["ignore", "pipe", "pipe"],
      shell: process.platform === "win32" && pgDumpBin === "pg_dump",
    });

    const out = createWriteStream(filepath);
    const gzip = createGzip();

    let errMsg = "";
    pgDump.stderr.on("data", (d) => {
      errMsg += d.toString();
    });

    const fail = async (error) => {
      const message =
        error?.code === "ENOENT"
          ? "pg_dump bulunamadı. PostgreSQL istemci araçlarını kurun veya PG_DUMP_PATH tanımlayın."
          : error?.message || errMsg || "Yedekleme başarısız.";
      logger.warn({ type: "admin_backup_failed", backupId, message });
      try {
        await prisma.dbBackup.update({
          where: { id: backupId },
          data: { status: "FAILED", errorMessage: message.slice(0, 500) },
        });
      } catch {
        /* ignore */
      }
      reject(new Error(message));
    };

    pipeline(pgDump.stdout, gzip, out)
      .then(async () => {
        const st = await stat(filepath);
        await prisma.dbBackup.update({
          where: { id: backupId },
          data: {
            status: "COMPLETED",
            sizeBytes: BigInt(st.size),
            completedAt: new Date(),
          },
        });
        resolve();
      })
      .catch(fail);

    pgDump.on("error", fail);
    pgDump.on("close", (code) => {
      if (code !== 0 && code !== null) {
        fail(new Error(errMsg || `pg_dump çıkış kodu ${code}`));
      }
    });
  });
}

export async function listBackupsService() {
  const rows = await prisma.dbBackup.findMany({
    orderBy: { createdAt: "desc" },
    take: 50,
    include: { createdBy: { select: { name: true, email: true } } },
  });
  return rows.map(serializeBackup);
}

export async function generateDownloadTokenService(adminId, backupId, ipAddress) {
  const backup = await prisma.dbBackup.findFirst({
    where: { id: backupId, status: "COMPLETED" },
  });
  if (!backup) throw new HttpError(404, "Yedek bulunamadı veya henüz tamamlanmadı.");

  const token = crypto.randomBytes(32).toString("hex");
  const hash = crypto.createHash("sha256").update(token).digest("hex");
  const expiresAt = new Date(Date.now() + 15 * 60 * 1000);

  await prisma.dbBackup.update({
    where: { id: backupId },
    data: { downloadTokenHash: hash, downloadTokenExpiresAt: expiresAt },
  });

  await writeAdminAuditLog({
    adminId,
    action: "BACKUP_DOWNLOAD_TOKEN",
    targetType: "DbBackup",
    targetId: backupId,
    ipAddress,
  });

  return { token, expiresAt, backupId };
}

export async function streamBackupDownload(backupId, token) {
  const hash = crypto.createHash("sha256").update(token).digest("hex");
  const backup = await prisma.dbBackup.findFirst({
    where: {
      id: backupId,
      status: "COMPLETED",
      downloadTokenHash: hash,
      downloadTokenExpiresAt: { gt: new Date() },
    },
  });
  if (!backup) throw new HttpError(403, "Geçersiz veya süresi dolmuş indirme bağlantısı.");

  const filepath = path.join(getBackupDir(), backup.filename);
  return { filepath, filename: backup.filename };
}
