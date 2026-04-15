import express from "express";
import cors from "cors";
import dotenv from "dotenv";

import aiRoute from "./routes/ai.route.js";

dotenv.config();

const app = express();

// middleware
app.use(cors());
app.use(express.json());

// routes
app.use('/api/ai', aiRoute);

// run check
app.get('/', (req, res) => {
    res.send("MeshGPT Running Fine!");
});

// start server
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log(`Server started on http://localhost:${PORT}`);
})