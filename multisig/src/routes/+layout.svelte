<script lang="ts">
	import initWeb3 from '$lib/web3';

    import { connected,  signerAddress  } from 'svelte-ethers-store'
	import { onMount } from 'svelte';

    $: console.log("connected:", $connected, $signerAddress );

    
    onMount(async () => {
        const res = await initWeb3();
    })

</script>

<h1>Welcome to SvelteKit</h1>

<slot />

