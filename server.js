const express = require('express');
const path = require('path');
const fs = require('fs');
const app = express();
const PORT = 3000;

app.use(express.static(path.join(__dirname)));
app.use(express.json());

app.post('/log-movement', (req, res) => {
    const { key } = req.body;
    fs.appendFile(path.join(__dirname, 'movement.txt'), key + '\n', (err) => {
        if (err) {
            console.error('Failed to write movement command to file:', err);
            res.status(500).send('Failed to write movement command');
        } else {
            res.send('Movement command updated');
        }
    });
});

app.post('/log-action', (req, res) => {
    const { action } = req.body;

    const parts = action.split('_');
    const actionType = parts[0];
    const x = parts[1];
    const y = parts[2];
    const id = parts.length > 3 ? parts[3] : null;

    let filePath;
    if (actionType === 'break') {
        filePath = path.join(__dirname, 'break.txt');
    } else if (actionType === 'place') {
        filePath = path.join(__dirname, 'place.txt');
    } else {
        return res.status(400).send('Invalid action type');
    }

    const line = id ? `${actionType}_${x}_${y}_${id}\n` : `${actionType}_${x}_${y}\n`;

    fs.appendFile(filePath, line, (err) => {
        if (err) {
            console.error('Failed to write action:', err);
            return res.status(500).send('Failed to write action');
        }
        res.sendStatus(200);
    });
});

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
