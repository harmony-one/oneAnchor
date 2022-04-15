require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {
    const Reserve = await ethers.getContractFactory("Reserve");
    const reserve = await Reserve.deploy();
    reserve.__Reserve_init();

    console.log("Reserve deployed to:", reserve.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });