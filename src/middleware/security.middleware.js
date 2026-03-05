import aj from '#config/arcjet.js';
import logger from '#config/logger.js';
import { slidingWindow } from '@arcjet/node';

const securityMiddleware = async (req, res, next) => {
  // Skip security checks in development mode
  if (process.env.NODE_ENV === 'development') {
    return next();
  }

  // Skip if no IP available (common in some cloud environments)
  if (!req.ip && !req.headers['x-forwarded-for']) {
    logger.warn('No IP address available, skipping Arcjet checks');
    return next();
  }

  try {
    const role = req.user?.role || 'guest';

    let limit;

    switch (role) {
      case 'admin':
        limit = 20;
        break;
      case 'user':
        limit = 10;
        break;
      case 'guest':
        limit = 5;
        break;
    }

    const client = aj.withRule(
      slidingWindow({
        mode: 'LIVE',
        interval: '1m',
        max: limit,
        name: `${role}-rate-limit`,
      })
    );

    const decision = await client.protect(req);

    // Never block requests, just log if Arcjet would have denied
    if (decision.isDenied()) {
      logger.warn('Arcjet would have denied this request', {
        reason: decision.reason,
        ip: req.ip,
        userAgent: req.get('User-Agent'),
        path: req.path,
        method: req.method,
      });
    }
    next();
  } catch (e) {
    // Log the error but don't block the request - fail open for availability
    console.error('Arcjet middleware error:', e);
    logger.warn('Arcjet check failed, allowing request to continue');
    next();
  }
};
export default securityMiddleware;
