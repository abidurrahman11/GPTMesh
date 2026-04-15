import express from "express";
import {handleAIRequest} from "../services/aiRouter.js";

const router = express.Router();

router.post('/ask', handleAIRequest);

export default router;