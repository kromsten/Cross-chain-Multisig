
import { defaultEvmStores } from 'svelte-ethers-store'


const initWeb3 = async() => {
    // @ts-ignore
    await defaultEvmStores.setProvider("http://localhost:8500/3")
}

export default initWeb3
