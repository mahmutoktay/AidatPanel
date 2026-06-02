/**
 * @template T, R
 * @param {T[]} items
 * @param {number} concurrency
 * @param {(item: T) => Promise<R>} worker
 * @returns {Promise<R[]>}
 */
export async function runPool(items, concurrency, worker) {
  if (items.length === 0) return [];
  const results = new Array(items.length);
  let index = 0;
  const workers = Array.from(
    { length: Math.min(concurrency, items.length) },
    async () => {
      while (index < items.length) {
        const i = index;
        index += 1;
        results[i] = await worker(items[i]);
      }
    }
  );
  await Promise.all(workers);
  return results;
}
