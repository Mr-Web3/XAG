import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
// import { Contract } from "ethers";
// import { ethers } from "ethers";

const XAGContracts: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy, log } = hre.deployments;

  const taxAddress = "0xB7a8616FB3E0256D2c085Cd6610c5129f53E5AE5";

  // Deploy XAG Token contract
  const XAGToken = await deploy("XAGToken", {
    from: deployer,
    args: [taxAddress],
    log: true,
    autoMine: true,
  });

  console.log("XAGToken contract deployed at:", XAGToken.address);

  // Get the deployed contract to interact with it after deploying.
  log(`DBROContracts deployed at ${XAGToken.address}`);
};

export default XAGContracts;
XAGContracts.tags = ["XAGToken"];
