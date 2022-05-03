require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {
    const OneAnchor = await ethers.getContractFactory("OneAnchor");
    const oneAnchor = await OneAnchor.deploy();
    oneAnchor.initialize();

    console.log("OneAnchor deployed to:", oneAnchor.address);
}   

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });