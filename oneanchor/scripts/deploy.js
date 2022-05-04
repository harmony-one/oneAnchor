require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {
    const OneAnchor = await ethers.getContractFactory("OneAnchor");
    // const oneAnchor = await OneAnchor.deploy();
    // await oneAnchor.initialize();

    const oneAnchor = await upgrades.deployProxy(OneAnchor, [], { initializer: "initialize" });

    let accounts = await ethers.getSigners();
    await oneAnchor.setOperatorRole(accounts[0].address);

    console.log("OneAnchor deployed to:", oneAnchor.address);
}   

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });