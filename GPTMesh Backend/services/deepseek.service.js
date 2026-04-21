import {OpenAI} from "openai";
import dotenv from "dotenv";
// Deepseek doesn't work without dotenv here
dotenv.config();

const deepseek = new OpenAI({
    baseURL: "https://api.deepseek.com",
    apiKey: process.env.DEEPSEEK_API_KEY,
});

export async function askDeepSeek(messages) {
    try {
        const response = await deepseek.chat.completions.create({
            messages: messages,
            model: "deepseek-chat",
        });

        return response.choices[0].message.content;
    } catch (error) {
        console.error("❌ DeepSeek Error:", error);
        throw new Error("DeepSeek failed");
    }
}