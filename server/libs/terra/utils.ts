import bech32 from 'bech32'

export async function getExchangeRate() {
    return 0;
}

export async function getAUSTbalance() {
    return 0;
}

export async function getUSTbalance() {
    return 0;
}

/* bech32 */
export function decodeTerraAddressOnEtherBase(address: string) {
    try {
      const { words } = bech32.bech32.decode(address)
      const data = bech32.bech32.fromWords(words)
      return '0x' + Buffer.from(data).toString('hex')
    } catch (error) {
      return ''
    }
  }