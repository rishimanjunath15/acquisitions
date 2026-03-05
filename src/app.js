import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';
import logger from '#config/logger.js';
import helmet from 'helmet';
import morgan from 'morgan';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import authRoutes from '#routes/auth.routes.js';
import securityMiddleware from '#middleware/security.middleware.js';
import userRoutes from '#routes/users.routes.js';

// Get absolute paths for ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const publicPath = path.join(__dirname, '../public');

const app = express();

// Trust proxy for AWS ECS/Fargate (needed for correct IP detection)
app.set('trust proxy', true);

// Configure Helmet for HTTP (disable HTTPS-only features for non-HTTPS deployment)
app.use(helmet({
  contentSecurityPolicy: false, // Disable CSP that blocks HTTP
  crossOriginOpenerPolicy: false, // Disable COOP that requires HTTPS
  crossOriginEmbedderPolicy: false, // Disable COEP
  originAgentCluster: false, // Disable Origin-Agent-Cluster header
  strictTransportSecurity: false, // Disable HSTS (requires HTTPS)
}));

app.use(cors());
app.use(express.json());
app.use(cookieParser());
app.use(
  morgan('combined', {
    stream: { write: message => logger.info(message.trim()) },
  })
);
app.use(securityMiddleware);
app.use(express.urlencoded({ extended: true }));

app.get('/', (req, res) => {
  // Check if request accepts JSON (API call) vs HTML (browser)
  if (req.accepts('json') && !req.accepts('html')) {
    logger.info('API call to root endpoint');
    return res.status(200).json({ message: 'hello from acquisitions API' });
  }

  // Browser request - serve the frontend
  logger.info('Browser request - serving frontend');
  res.sendFile(path.join(publicPath, 'index.html'));
});

// Serve static files from public directory (using absolute path)
app.use(express.static(publicPath));

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

app.get('/api', (req, res) => {
  res.status(200).json({ message: 'Acquisitions API is running!' });
});

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);

app.use((req, res) => {
  res.status(404).json({ error: 'route not found' });
});

// Global JSON error handler — must have 4 params for Express to treat it as an error handler
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  logger.error('Unhandled error', { message: err.message, stack: err.stack });
  const status = err.status || err.statusCode || 500;
  res.status(status).json({
    error: err.message || 'Internal server error',
  });
});

export default app;
