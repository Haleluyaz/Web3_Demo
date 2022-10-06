require('dotenv').config();

const express = require('express');
const { ethers, utils } = require('ethers');
const fs = require('fs');
const { join } = require('path');
const cors = require('cors')
const port = 5000;
const app = express();
app.use(cors());

app.get('/', async (req, res) => {
    const rawJson = fs.readFileSync(join('./', 'abi.json'), 'utf8');
    const abi = JSON.parse(rawJson);
    const provider = new ethers.providers.JsonRpcProvider(`${process.env.GORELI_URL}`, 5);
    const contract = new ethers.Contract(
        `${process.env.CONTRACT_ADDRESS}`,
        abi,
        provider)
    
    const goalTask = contract.goal().then(res => utils.formatEther(res));
    const poolTask = contract.pool().then(res => utils.formatEther(res));
    const endTimeTask = contract.endTime().then(res => res * 1000);
    
    const [goal, pool, endTime] = [await goalTask, await poolTask, await endTimeTask]
    const progress =((pool / goal) * 100).toPrecision(4)
    
    res.json({goal, pool, endTime, progress});
})

app.listen(port, () => {
    console.log("Running on port ${port}");
})

module.export = app;