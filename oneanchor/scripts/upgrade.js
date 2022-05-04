// scripts/upgrade-box.js
const { ethers, upgrades } = require("hardhat");

async function main() {
    const OneAnchor = await ethers.getContractFactory("OneAnchor");
    const oneAnchor = await upgrades.upgradeProxy(
        process.env.ONE_ANCHOR_CONTRACT,
        OneAnchor
    );
    console.log("oneAnchor upgraded");

    
    // console.log(await onebtc.changeRelayer(process.env.HMY_RELAY_CONTRACT));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });