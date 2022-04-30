import { balanceReserves } from './libs/oneAnchor/deamons'
import { setListeners } from './libs/oneAnchor/listeners'
import 'dotenv/config'
import { log } from './libs/logs'

var minutes = Number(process.env.DEAMON_MINUTES);
var the_interval = minutes * 60 * 1000;

setListeners();
log("starting deamons");
setInterval(function() {
  balanceReserves();
}, the_interval);