/**
 * Express 5+: req.query / req.params çoğu durumda salt okunur; doğrudan atama TypeError verir.
 */
const setReadonlyRequestProp = (req, key, value) => {
  Object.defineProperty(req, key, {
    value,
    enumerable: true,
    configurable: true,
  });
};

/**
 * Zod schema validation middleware'i oluşturur.
 * @param {{ body?: import("zod").ZodSchema, query?: import("zod").ZodSchema, params?: import("zod").ZodSchema }} schema
 */
export const validate = (schema) => {
  return (req, res, next) => {
    try {
      if (schema.body) {
        req.body = schema.body.parse(req.body);
      }

      if (schema.query) {
        const parsed = schema.query.parse(req.query ?? {});
        setReadonlyRequestProp(req, "query", parsed);
      }

      if (schema.params) {
        const parsed = schema.params.parse(req.params ?? {});
        setReadonlyRequestProp(req, "params", parsed);
      }

      next();
    } catch (error) {
      next(error);
    }
  };
};
