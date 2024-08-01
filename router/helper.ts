import { Token } from "@uniswap/sdk-core";
import { Environment, PEPE, WETH_TOKEN } from "./constant";

export function fromReadableAmount(amount: number, decimals: number) {
    const extraDigits = Math.pow(10, countDecimals(amount));
    const adjustedAmount = Math.floor(amount * extraDigits);
    return BigInt(adjustedAmount) * BigInt(10 ** decimals) / BigInt(extraDigits);
  }
  
  export function toReadableAmount(rawAmount: bigint, decimals: number) {
    return (BigInt(rawAmount) / BigInt(10 ** decimals)).toString();
  }
  
  function countDecimals(x: number) {
    if (Math.floor(x) === x) {
      return 0;
    }
    return x.toString().split('.')[1].length || 0;
  }

  // Inputs that configure this example to run
export interface ExampleConfig {
  env: Environment
  rpc: {
    local: string
    mainnet: string
  }
  wallet: {
    address: string
    privateKey: string
  }
  currencies: {
    in: Token
    amountIn: number
    out: Token
  },
}


export const CurrentConfig: ExampleConfig = {
  env: Environment.LOCAL,
  rpc: {
    local: 'http://localhost:8545',
    mainnet: '',
  },
  wallet: {
    address: '0x67ff09c184d8e9e7B90C5187ED04cbFbDba741C8',
    privateKey:
      '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80',
  },
  currencies: {
    in: WETH_TOKEN,
    amountIn: 1,
    out: PEPE,
  },
}

function getConfig() {
  return CurrentConfig
}