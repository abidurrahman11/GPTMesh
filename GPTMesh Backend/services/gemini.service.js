import { GoogleGenAI } from "@google/genai";

const genAI = new GoogleGenAI({apiKey: process.env.GEMINI_API_KEY});

export async function askGemini(messages) {
    try {
        const response = await genAI.interactions.create({
            model: 'gemini-2.5-flash',
            input: messages,
        });

        return response.text;
    } catch (error) {
        console.error("❌ Gemini Error:", error);
        throw new Error("Gemini failed");
    }
}