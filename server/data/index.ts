import fs from 'fs';
import * as path from 'path';
import {log} from '../libs/logs';

let name = path.resolve(__dirname, './db.json')
var db = JSON.parse(fs.readFileSync(name).toString());

export function getData() {
    return db;
}

export function updateAUST(amount: number) {
    log("Updating aUST pending loads in the db", [["amount",amount.toString(),"number"]]);
    db.aust += amount;
    fs.writeFileSync(name, JSON.stringify(db));
}

export function updateUST(amount: number) {
    log("Updating UST pending loads in the db", [["amount",amount.toString(),"number"]]);
    db.ust += amount;
    fs.writeFileSync(name, JSON.stringify(db));
}


