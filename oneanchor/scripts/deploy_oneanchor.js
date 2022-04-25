require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {
    const Reserve = await ethers.getContractFactory("Reserve");
    const reserve = await Reserve.attach(
        process.env.HMY_RESERVE_CONTRACT
    );

    const OneAnchor = await ethers.getContractFactory("OneAnchor");
    const oneAnchor = await OneAnchor.deploy();
    oneAnchor.__OneAnchor_init(reserve.address);

    console.log("OneAnchor deployed to:", oneAnchor.address);
}   

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });