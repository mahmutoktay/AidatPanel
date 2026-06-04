/**
 * Controller / service katmanında HTTP durum kodu ile hata fırlatmak için.
 * errorHandler `statusCode` alanını okur.
 */
export class HttpError extends Error {
  /**
   * @param {number} statusCode
   * @param {string} message
   * @param {object} [data] — JSON `data` alanı (ör. 409 duplicate dekont)
   */
  constructor(statusCode, message, data = undefined) {
    super(message);
    this.name = "HttpError";
    this.statusCode = statusCode;
    this.data = data;
  }
}
