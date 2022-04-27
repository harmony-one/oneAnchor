import fs from 'fs'
import util from 'util'
import * as path from 'path';
import 'dotenv/config'

let name = path.resolve(__dirname, './' + process.env.LOGGING_FILENAME)
var log_file = fs.createWriteStream(name, {flags : 'w'});
var log_stdout = process.stdout;

function addParameters(params: [[string, string, string]]) {
    var result = "";
    for (const param in params) {
        result += " " + param[0] + " " + param[1] + " " + param[2];
    }
    return result;
}

export function log(message: string, params: [[string, string, string]]) {
    let date_ob = new Date();
    let date = ("0" + date_ob.getDate()).slice(-2);
    let month = ("0" + (date_ob.getMonth() + 1)).slice(-2);
    let year = date_ob.getFullYear();
    let hours = date_ob.getHours();
    let minutes = date_ob.getMinutes();
    let seconds = date_ob.getSeconds();
    let datetime = year + "-" + month + "-" + date + " " + hours + ":" + minutes + ":" + seconds;
    var d = datetime + " " + message + addParameters(params);
    log_file.write(util.format(d) + '\n');
    log_stdout.write(util.format(d) + '\n');
}
