import express from 'express';
import logger from '#config/logger.js';
import helmet from 'helmet';
import morgan from 'morgan';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import authRoutes from '#routes/auth.routes.js';
import securityMiddleware from '#middleware/security.middleware.js';
import userRoutes from '#routes/users.routes.js';

const app = express();
app.use(helmet());
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
  res.sendFile('index.html', { root: 'public' });
});

// Serve static files from public directory
app.use(express.static('public'));

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

export default app;
