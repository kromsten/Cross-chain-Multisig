import type { IGunInstance } from "gun/types/gun/"
import Gun from "gun/gun"


const gun : IGunInstance = new Gun('http://127.0.0.1:8765/gun')
export default gun;