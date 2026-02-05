const express = require('express');
const app = express();
const port = 3000;

// Version variable - update this to test rollouts
const version = '1.0.0';

app.get('/', (req, res) => {
  res.json({ version: version });
});

app.get('/health', (req, res) => {
  res.send('OK');
});

app.listen(port, () => {
  console.log(`Argo Canary app listening on port ${port}, version ${version}`);
});
