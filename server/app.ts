import {checkForPendingLoad, balanceReserves} from './libs/oneAnchor/deamons'
import 'dotenv/config'
import {log} from './libs/logs'

var minutes = Number(process.env.DEAMON_MINUTES);
var the_interval = minutes * 60 * 1000;

setInterval(function() {
  log("starting deamons",null);
    checkForPendingLoad();
    balanceReserves();
  }, the_interval);