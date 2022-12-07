import { writable, type Writable } from 'svelte/store'
import type { IGunInstance } from "gun/types/gun/"
import Gun from "gun/gun"


class Signatures {
  
  private gun: IGunInstance
  private name: string;
  private store: Writable<any> 

  constructor(name : string) {
    this.gun = new Gun('http://127.0.0.1:8765/gun')
    this.name = name
    
    this.store = writable(0)

    this.store.subscribe(data => {
      this.current = data
    })
    this.gun.get(name).get('value').on(data => {
      if (data.value !== this.current) {
        this.localStore.set(data)
      }
    })
  }

  subscribe(cb) {
    return this.localStore.subscribe(cb)
  } 

  set(value) {
    this.gun.get(this.name).get('value').put(value)
    return this.localStore.set(value)
  }
}

export const counter = new Signatures('multiSignatures')