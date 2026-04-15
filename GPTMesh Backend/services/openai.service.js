import {OpenAI} from "openai";

const openAI = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
});

export async function askOpenAI (prompt) {
    try {
        const response = openAI.chat.completions.create({
            model: "gpt-4o-mini",
            messages: [{
                role: 'system',
                content: 'You are a helpful AI assistant.'
            },
            {
                role: 'user',
                content: prompt,
            }],
            temperature: 0.7,
        });
        return response.choices[0].message.content;
    } catch (error) {
        console.error("❌ OpenAI Error:", error);
        throw new Error("OpenAI failed");
    }
}