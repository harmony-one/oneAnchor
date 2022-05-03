require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {
    const OneAnchor = await ethers.getContractFactory("OneAnchor");
    const oneAnchor = await OneAnchor.attach(
        process.env.ONE_ANCHOR_CONTRACT
    );
    await oneAnchor.setOperatorRole("");
    console.log("OneAnchor deployed to:", oneAnchor.address);
}   

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });