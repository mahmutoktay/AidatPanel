const { PrismaClient } = require('@prisma/client');
const p = new PrismaClient();
p.subscription.findMany().then(r => {
  console.log('Subscriptions:', r.length);
  if (r.length > 0) console.log(JSON.stringify(r, null, 2));
  p.$disconnect();
}).catch(e => {
  console.error('Error:', e.message);
  p.$disconnect();
});
