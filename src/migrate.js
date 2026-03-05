import 'dotenv/config';
import { drizzle } from 'drizzle-orm/neon-http';
import { neon } from '@neondatabase/serverless';
import { migrate } from 'drizzle-orm/neon-http/migrator';

// Configure Neon for local Docker development (neon-local proxy)
let config = {};
if (process.env.NODE_ENV === 'development' && process.env.DATABASE_URL?.includes('neon-local')) {
  const neonLocalHost = process.env.NEON_LOCAL_HOST || 'neon-local';
  config = {
    fetchEndpoint: `http://${neonLocalHost}:5432/sql`,
    useSecureWebSocket: false,
    poolQueryViaFetch: true,
  };
}

const sql = neon(process.env.DATABASE_URL, config);
const db = drizzle(sql);

async function main() {
  console.log('🔄 Running migrations...');

  try {
    await migrate(db, { migrationsFolder: './drizzle' });
    console.log('✅ Migrations completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

main();
