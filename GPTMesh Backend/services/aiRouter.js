import {askDeepSeek} from "../services/deepseek.service.js";
import {askOpenAI} from "../services/openai.service.js";
import {askClaude} from "../services/claude.service.js";
import {askGemini} from "../services/gemini.service.js";

export async function handleAIRequest(req, res) {
    try {
        const {model, prompt} = req.body;
        if (!model || !prompt) {
            return res.status(400).json({
                success: false,
                message: 'Model and prompt are required',
            });
        }

        let response;
        // handle different AI models
        switch (model) {
            case "openai":
                response = await askOpenAI(model);
                break;

            case "gemini":
                response = await askGemini(prompt);
                break;

            case "claude":
                response = await askClaude(prompt);
                break;

            case "deepseek":
                response = await askDeepSeek(prompt);
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