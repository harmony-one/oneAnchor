require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {
    const ERC20 = await ethers.getContractFactory("ERC20Upgradeable");
    let erc20 = await ERC20.attach(
        process.env.WUST
    );
    let accounts = await ethers.getSigners();
    let owner = accounts[0].address;
    let spender = process.env.ONE_ANCHOR_CONTRACT;
    // 100 UST approve
    await erc20.approve(spender, "0x56BC75E2D63100000", {gasLimit: process.env.GAS_LIMIT});
    console.log("owner UST balance", await erc20.balanceOf(owner));
    console.log("spender UST balance", await erc20.balanceOf(spender));
    console.log("UST allowance", await erc20.allowance(owner, spender));
    // 300 aUST approve
    erc20 = await ERC20.attach(
        process.env.WAUST
    );
    await erc20.approve(spender, "0x1043561A8829300000", {gasLimit: process.env.GAS_LIMIT});
    console.log("owner aUST balance", await erc20.balanceOf(owner));
    console.log("spender aUST balance", await erc20.balanceOf(spender));
    console.log("aUST allowance", await erc20.allowance(owner, spender));
    
    
    // console.log("OneAnchor deployed to:", oneAnchor);
}   

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });