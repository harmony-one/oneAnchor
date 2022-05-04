require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {
    const OneAnchor = await ethers.getContractFactory("OneAnchor");
    const oneAnchor = await OneAnchor.attach(
        process.env.ONE_ANCHOR_CONTRACT
    );
    // let ustAmount = "0x56BC75E2D63100000";
    let austAmount = "0x56BC75E2D63100000";
    let terraAddr = "0x1a1160a8cac7992b3588384b02d8c0eaf83b42b0000000000000000000000000";
    // await oneAnchor.depositUSTOperator(ustAmount, {gasLimit: process.env.GAS_LIMIT});
    await oneAnchor.withdrawAUSTOperator(austAmount, terraAddr, {gasLimit: process.env.GAS_LIMIT});
    
    // console.log("OneAnchor USTBalance:", await oneAnchor.USTBalance());
    // console.log("OneAnchor aUSTBalance:", await oneAnchor.aUSTBalance());

    // let accounts = await ethers.getSigners();
    // let owner = accounts[0].address;
    
}   

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });