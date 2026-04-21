import Groq from "groq-sdk";

const groq = new Groq({
    apiKey: process.env.GROQ_API_KEY
});


export async function askQwen(messages) {
    try {
        const response = await groq.chat.completions.create({
            messages: messages,
            model: "qwen/qwen3-32b",
        });

        const rawContent = response.choices[0].message.content;
        // remove the thinking part of AI from response
        const cleanContent = rawContent.replace(/<think>[\s\S]*?<\/think>/g, "").trim();
        return cleanContent;
    } catch (error) {
        console.error("❌ Qwen Error:", error);
        throw new Error("Qwen Failed");
    }
}