import express from "express";
import subscriptionsRoutes from "./subscriptionsRoutes.js";

const router = express.Router();

router.use("/", subscriptionsRoutes);

export default router;
