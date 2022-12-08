import type { IGunInstance } from "gun/types/gun/"
import Gun from "gun/gun"


const options = {
    peers: ['http://localhost:8765/gun', "http://gun-manhattan.herokuapp.com/gun"],
    localStorage: true,
    radisk: false,

}


const gun : IGunInstance = new Gun(options)

Gun.log = { off: true, once: () => {} }



export default gun;