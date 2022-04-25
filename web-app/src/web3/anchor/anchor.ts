import { MnemonicKey, AnchorEarn, CHAINS, NETWORKS, DENOMS, MarketOutput, MarketEntry } from '@anchor-protocol/anchor-earn'

export async function getApy() {
  try {
      const account = new MnemonicKey({
          mnemonic: process.env.MNEMONIC,
      });
      const anchorEarn = new AnchorEarn({
          chain: CHAINS.TERRA,
          network: NETWORKS.COLUMBUS_5,
          privateKey: account.privateKey,
        });
        const marketInfo = await anchorEarn.market({
          currencies: [
            DENOMS.UST
          ],
        }) as MarketOutput
        const market = marketInfo.markets[0] as MarketEntry
        if (market.APY) {
          return (parseFloat(market.APY) * 100).toFixed(2);
        } else {
          return null;
        }
  } catch(error) {
      console.log(error)
  }

}