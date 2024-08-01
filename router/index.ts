import { ethers } from "ethers"
import { AlphaRouter, SwapOptionsSwapRouter02, SwapType } from "@uniswap/smart-order-router"
import express, { Request, Response } from 'express';
import { CurrencyAmount, Percent, Token, TradeType } from "@uniswap/sdk-core";
import { CurrentConfig, fromReadableAmount } from "./helper";
import cors from 'cors';

const app = express();
const port = process.env.PORT || 3000;
const allowedOrigins = ['http://localhost:5173'];

const options: cors.CorsOptions = {
  origin: allowedOrigins,
  credentials: true
};

app.use(cors(options));
app.use(express.json());



app.get('/:contractAddressOne/:decimalOne/:symbolOne/:contractAddressTwo/:decimalsTwo/:symbolTwo/:amount/:walletAddress', async (req: Request, res: Response) => {
  console.log("called")
  const provider = new ethers.providers.JsonRpcProvider(" https://eth-mainnet.g.alchemy.com/v2/PvfO5LG_yc2T_5n45hAAa9FME3UHgiw3 ");
  const { contractAddressOne, contractAddressTwo, amount, decimalOne, symbolOne, decimalsTwo, symbolTwo ,walletAddress} = req.params;
  const tokenOne = new Token(1, contractAddressOne, parseInt(decimalOne), symbolOne, symbolOne);
  const tokenTwo = new Token(1, contractAddressTwo, parseInt(decimalsTwo), symbolTwo, symbolTwo);
  const router = new AlphaRouter({
    chainId: 1,
    provider,
  })
  const rawTokenAmountIn = fromReadableAmount(
    Number(amount),
    tokenOne.decimals
  )
  console.log(rawTokenAmountIn)
  const options: SwapOptionsSwapRouter02 = {
    recipient: walletAddress,
    slippageTolerance: new Percent(50, 10_000),
    deadline: Math.floor(Date.now() / 1000 + 1800),
    type: SwapType.SWAP_ROUTER_02,
  }
  console.log(options)
  const route = await router.route(
    CurrencyAmount.fromRawAmount(
      tokenOne,
      rawTokenAmountIn.toString()
    ),
    tokenTwo,
    TradeType.EXACT_INPUT,
    options
  )
  console.log(route)
  res.send({ routeCallData: route?.methodParameters?.calldata, routeValue: route?.methodParameters?.value,qoute:route?.quote.toExact() })

});


app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});


