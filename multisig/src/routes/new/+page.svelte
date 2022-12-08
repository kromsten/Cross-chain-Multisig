<script lang="ts">
    import { arrayify, verifyMessage, recoverAddress, toUtf8Bytes, keccak256, recoverPublicKey, hashMessage, computeAddress, sha256 } from "ethers/lib/utils"
    import { connected,  signerAddress, signer, provider  } from 'svelte-ethers-store'
    
    $: lurkers = []

    const toSign : string = "Data to sign";


    function toHex(str : string) : string{
        var result = '';
        for (var i=0; i<str.length; i++) {
        result += str.charCodeAt(i).toString(16);
        }
        return result;
    }
    
    const sign = async () => {
        
        if ($connected ) {

            const address = $signerAddress
            
            const sig = await $signer.signMessage(toSign)

            const msgHash = hashMessage(toSign);
            const msgHashBytes = arrayify(msgHash);
            const recoveredPubKey = recoverPublicKey(msgHashBytes, sig);
            const recoveredAddress = recoverAddress(msgHashBytes, sig);
            const raddress = computeAddress(recoveredPubKey)
            console.log("ad:", address, recoveredAddress, raddress);




            /* await window.ethereum.request({
                method: 'eth_sign',
                params: [$signerAddress, utils.sha256(toSign)]
            }); */
        }
    }
</script>


<h1>Creating new multisig</h1>

<div class="container">
    <h3>Data to sign::</h3>

    <textarea value={toSign} disabled />

    <button disabled={!$connected} on:click={sign}>Sign</button>

    <div>
        <h6>Signatures:</h6>
        <ul>
            { #each lurkers as lurker (lurker)}
                <li>Lurker: {lurker }</li>
            {/each}
        </ul>
    </div>
</div>


<div>
    <button>Create new multisig</button>
</div>