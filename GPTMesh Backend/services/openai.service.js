import {OpenAI} from "openai";

const openAI = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
});

export async function askOpenAI (messages) {
    try {
        const response = await openAI.chat.completions.create({
            model: "gpt-4o-mini",
            messages: messages,
            temperature: 0.7,
        });
        return response.choices[0].message.content;
    } catch (error) {
        console.error("❌ OpenAI Error:", error);
        throw new Error("OpenAI failed");
    }
}