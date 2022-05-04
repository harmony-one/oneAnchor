require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {
    const OneAnchor = await ethers.getContractFactory("OneAnchor");
    const oneAnchor = await OneAnchor.attach(
        process.env.ONE_ANCHOR_CONTRACT
    );
    let ustAmount = "0x56BC75E2D63100000";
    let austAmount = "0x1043561A8829300000";
    await oneAnchor.depositUSTOperator(ustAmount, {gasLimit: process.env.GAS_LIMIT});
    await oneAnchor.depositAUSTOperator(austAmount, {gasLimit: process.env.GAS_LIMIT});
    
    console.log("OneAnchor USTBalance:", await oneAnchor.USTBalance());
    console.log("OneAnchor aUSTBalance:", await oneAnchor.aUSTBalance());
    
}   

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });