// server.js
// Entry point: loads env vars, tests DB connection, then starts the server.

require('dotenv').config();

const app = require('./src/app');
const { testConnection } = require('./src/config/db');

const PORT = process.env.PORT || 3001;

async function start() {
  await testConnection();
  const server = app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
  });

  server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
      console.error(`❌ Port ${PORT} is already in use. Run: lsof -ti :${PORT} | xargs kill -9`);
      process.exit(1);
    } else {
      throw err;
    }
  });
}

start();
