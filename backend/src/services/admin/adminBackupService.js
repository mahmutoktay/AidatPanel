import { spawn } from "node:child_process";
import crypto from "node:crypto";
import { createWriteStream } from "node:fs";
import { mkdir, stat } from "node:fs/promises";
import path from "node:path";
import { prisma } from "../../config/db.js";
import { HttpError } from "../../utils/httpError.js";
import { writeAdminAuditLog } from "./adminAuditService.js";

function getBackupDir() {
  return process.env.ADMIN_BACKUP_DIR || "/var/backups/aidatpanel";
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

  return record;
}

function runPgDump(filepath, backupId) {
  return new Promise((resolve, reject) => {
    const dbUrl = parseDatabaseUrl();
    const args = ["--dbname", dbUrl, "--no-owner", "--no-acl"];
    const gzip = spawn("gzip", ["-c"], { stdio: ["pipe", "pipe", "pipe"] });
    const pgDump = spawn("pg_dump", args, { stdio: ["ignore", "pipe", "pipe"] });

    const out = createWriteStream(filepath);
    pgDump.stdout.pipe(gzip.stdin);
    gzip.stdout.pipe(out);

    let errMsg = "";
    pgDump.stderr.on("data", (d) => { errMsg += d.toString(); });
    gzip.stderr.on("data", (d) => { errMsg += d.toString(); });

    out.on("finish", async () => {
      try {
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
      } catch (e) {
        reject(e);
      }
    });

    out.on("error", reject);
    pgDump.on("error", reject);
    pgDump.on("close", (code) => {
      if (code !== 0) reject(new Error(errMsg || `pg_dump exit ${code}`));
    });
  });
}

export async function listBackupsService() {
  return prisma.dbBackup.findMany({
    orderBy: { createdAt: "desc" },
    take: 50,
    include: { createdBy: { select: { name: true, email: true } } },
  });
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
