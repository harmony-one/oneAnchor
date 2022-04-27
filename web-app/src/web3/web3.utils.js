import Web3 from "web3";

import tokensABI from './contracts/tokens-abi';
import incomeABI from './contracts/income-abi';

window.ethereum.enable();

export const AUST_CONTRACT = process.env.REACT_APP_AUST_CONTRACT_ADDRESS;
const incomeContractAddress = process.env.REACT_APP_INCOME_CONTRACT_ADDRESS;

const Web3Client = new Web3(window.web3.currentProvider);

const getContract = (abi, address) => {
  return new Web3Client.eth.Contract(abi, address);
}

export const getTokenBalance = async (walletAddress, tokenAddress, setBalance) => {
  const contract = getContract(tokensABI, tokenAddress);
  const result = await contract.methods.balanceOf(walletAddress).call(); 
  setBalance(parseFromWei(result));
}

export const incomeDeposit = async (wallet, amount, setValidationError) => {
  try {
    const amountWei = parseToWei(amount);
    if (parseInt(wallet.balance) > parseInt(amountWei)) {
      const contract = getContract(incomeABI,incomeContractAddress);
      const result = await contract.methods.deposit().send({ value: amountWei, from: wallet.account});
      return result; 
    } else {
      setValidationError('Not enough funds');
      return null;
    }
  } catch(e) {
    console.log(e);
    //console.log('HASH',JSON.parse(e));
    console.log('HASH2',e.receipt.transactionHash);
    throw (e); //'Transaction cancel');
  } 

}

export const incomeWithdraw = async (wallet, amount, setValidationError) => {
  try {
    const amountWei = parseToWei(amount);
    if (parseInt(wallet.balance) > parseInt(amountWei)) {
      const contract = getContract(incomeABI,incomeContractAddress);
      const result = await contract.methods.deposit().send({ value: amountWei, from: wallet.account});
      return result; 
    } else {
      setValidationError('Not enough funds');
      return null;
    }
  } catch(e) {
    console.log(e)
    throw (e); //'Transaction cancel');
  } 

}

export const parseFromWei = (wei) => {
  return parseFloat(Web3Client.utils.fromWei(wei)).toFixed(2); 
}

export const parseToWei = (amount) => {
  return Web3Client.utils.toWei(amount); 

}

export const truncateAddressString = (address, num = 12) => {
  if (!address) {
    return '';
  }
  const first = address.slice(0, num);
  const last = address.slice(-num);
  return `${first}...${last}`;
}