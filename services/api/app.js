const tracer = require('dd-trace').init();
const express = require('express');
const app = express();

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.get('/', (req, res) => res.send('Hello from sample API'));

const port = process.env.PORT || 8080;
app.listen(port, () => console.log(`listening on ${port}`));
