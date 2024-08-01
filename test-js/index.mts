import { ethers } from "ethers"
import { AlphaRouter, SwapOptionsSwapRouter02, SwapOptionsUniversalRouter, SwapType } from "@uniswap/smart-order-router"

export function fromReadableAmount(amount: number, decimals: number) {
  const extraDigits = Math.pow(10, countDecimals(amount));
  const adjustedAmount = amount * extraDigits;
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
import { CurrencyAmount, Percent, Token, TradeType } from '@uniswap/sdk-core'

import { SUPPORTED_CHAINS } from '@uniswap/sdk-core'
import { ABI } from "./abi";


export const V3_SWAP_ROUTER_ADDRESS =
  '0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45'
export const WETH_CONTRACT_ADDRESS =
  '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'


export const USDC_TOKEN = new Token(
  SUPPORTED_CHAINS[0],
  '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
  6,
  'USDC',
  'USD//C'
)

export const LINK_TOKEN = new Token(
  SUPPORTED_CHAINS[0],
  '0x514910771AF9Ca656af840dff83E8264EcF986CA',
  18,
  'LINK',
  'Chainlink Token'
)

export const DAI = new Token(
  SUPPORTED_CHAINS[0],
  '0x6B175474E89094C44Da98b954EedeAC495271d0F',
  18,
  'DAI',
  'DAI Stablecoin'
)
export const PEPE = new Token(
  SUPPORTED_CHAINS[0],
  '0x6982508145454Ce325dDbE47a25d4ec3d2311933',
  18,
  'PEPE',
  'PEPE Stablecoin'
)
// ABI's

export const ERC20_ABI = [
  // Read-Only Functions
  'function balanceOf(address owner) view returns (uint256)',
  'function decimals() view returns (uint8)',
  'function symbol() view returns (string)',

  // Authenticated Functions
  'function transfer(address to, uint amount) returns (bool)',
  'function approve(address _spender, uint256 _value) returns (bool)',

  // Events
  'event Transfer(address indexed from, address indexed to, uint amount)',
]

export const WETH_ABI = [
  // Wrap ETH
  'function deposit() payable',

  // Unwrap ETH
  'function withdraw(uint wad) public',
]

// Transactions

export const MAX_FEE_PER_GAS = 100000000000
export const MAX_PRIORITY_FEE_PER_GAS = 100000000000
export const TOKEN_AMOUNT_TO_APPROVE_FOR_TRANSFER = 10000

// Sets if the example should run locally or on chain
export enum Environment {
  LOCAL,
  WALLET_EXTENSION,
  MAINNET,
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
    in: LINK_TOKEN,
    amountIn: 1,
    out: DAI,
  },
}

async function main() {

  const provider = new ethers.providers.JsonRpcProvider("http://localhost:8545");
  // console.log(" provider", provider)
  ///@ts-ignore
  const router = new AlphaRouter({
    chainId: 1,
    provider,
  })

  // console.log(" router", router)


  const rawTokenAmountIn = fromReadableAmount(
    CurrentConfig.currencies.amountIn,
    CurrentConfig.currencies.in.decimals
  )



  const options: SwapOptionsSwapRouter02 = {
    recipient: CurrentConfig.wallet.address,
    slippageTolerance: new Percent(50, 10_000),
    deadline: Math.floor(Date.now() / 1000 + 18000),
    type: SwapType.SWAP_ROUTER_02,
  }

  // console.log("options", options)
  const route = await router.route(
    CurrencyAmount.fromRawAmount(
      CurrentConfig.currencies.in,
      rawTokenAmountIn.toString()
    ),
    CurrentConfig.currencies.out,
    TradeType.EXACT_INPUT,
    options
  )
  console.log(route?.methodParameters?.calldata)
  // if(route?.methodParameters?.calldata)
  // console.log(ethers.utils.hexStripZeros(route?.methodParameters?.calldata))


// function ensureHexCompatibility(hexString) {
//   // Remove the '0x' prefix if it exists
//   if (hexString.startsWith('0x')) {
//     hexString = hexString.slice(2);
//   }

//   // Ensure the hex string has an even number of characters
//   if (hexString.length % 2 !== 0) {
//     hexString = '0' + hexString;
//   }

//   // Add '0x' prefix
//   return '0x' + hexString;
// }

// const originalHex = "0x5ae401dc0000000000000000000000000000000000000000000000000000000066aaf9f700000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000e4472b43f30000000000000000000000000000000000000000000000000de0b6b3a7640000000000000000000000000000000000000000000000000000b4438a9dd121d6c00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb922660000000000000000000000000000000000000000000000000000000000000002000000000000000000000000514910771af9ca656af840dff83e8264ecf986ca0000000000000000000000006b175474e89094c44da98b954eedeac495271d0f00000000000000000000000000000000000000000000000000000000";

// const compatibleHex = ensureHexCompatibility(originalHex);
// console.log(compatibleHex);
  // if (route?.methodParameters) {
  //   console.log("valid route", route)
  //   const wallet = new ethers.Wallet("0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80", provider)
  //   const tokenContract = new ethers.Contract(
  //     CurrentConfig.currencies.in.address,
  //     ABI,
  //     wallet
  //   )
  //   const tokenApproval = await tokenContract.approve(
  //     V3_SWAP_ROUTER_ADDRESS,
  //     ethers.BigNumber.from(rawTokenAmountIn.toString())
  //   )
  //   console.log(tokenApproval)

  //   const txRes = await wallet.sendTransaction({
  //     data: route.methodParameters.calldata,
  //     to: V3_SWAP_ROUTER_ADDRESS,
  //     value: route.methodParameters.value,
  //     from: wallet.address,
  //     maxFeePerGas: MAX_FEE_PER_GAS,
  //     maxPriorityFeePerGas: MAX_PRIORITY_FEE_PER_GAS,
  //     gasLimit: 2000000
  //   })
  //   txRes.wait()
  //   console.log(txRes)
  // }
}



main()