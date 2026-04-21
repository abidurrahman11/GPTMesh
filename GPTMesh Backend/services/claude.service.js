import Anthropic from '@anthropic-ai/sdk'

const anthropic = new Anthropic({
    apiKey: process.env.CLAUDE_API_KEY,
});

export async function askClaude(messages) {
    try {
        const msg = await anthropic.messages.create({
            model: 'claude-3-haiku-20240307',
            max_tokens: 1000,
            messages: messages,
        });

        return msg.content[0].text;
    } catch (error) {
        console.error("❌ Claude Error:", error);
        throw new Error("Claude failed");
    }
}