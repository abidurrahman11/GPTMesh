import {askDeepSeek} from "./deepseek.service.js";
import {askOpenAI} from "./openai.service.js";
import {askClaude} from "./claude.service.js";
import {askGemini} from "./gemini.service.js";
import {askQwen} from "./qwen.service.js";

export async function handleAIRequest(req, res) {
    try {
        const {messages, model} = req.body;
        if (!model || !messages) {
            return res.status(400).json({
                success: false,
                message: 'Model and prompt are required',
            });
        }

        let response;
        // handle different AI models
        switch (model) {
            case "openai":
                response = await askOpenAI(messages);
                break;

            case "gemini":
                response = await askGemini(messages);
                break;

            case "claude":
                response = await askClaude(messages);
                break;

            case "deepseek":
                response = await askDeepSeek(messages);
                break;

            case "qwen":
                response = await askQwen(messages);
                break;

            default:
                return res.status(400).json({
                    success: false,
                    message: "Invalid model selected",
                });
        }
        res.json({
            success: true,
            model,
            text: response,
        });
    } catch (error) {
        console.error("❌ AI Router Error:", error);

        res.status(500).json({
            success: false,
            message: error.message || "AI request failed",
        });
    }
}