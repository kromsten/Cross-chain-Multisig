import gun from "./gun";
import { writable, type Writable } from 'svelte/store'

type RoomData = {
  a : string
};

type Rooms = {
  [id: string]: RoomData 
}


class RoomStore {
  private readonly name: string = "multisig_rooms";
  
  private rooms : Rooms = {}
  private roomsStore : Writable<Rooms>;

  constructor() {
    this.roomsStore = writable({})
    this.roomsStore.subscribe(rooms => {
      this.rooms = rooms
    })
    gun.get(this.name).on((room) => {
      this.roomsStore.set({
        ...this.rooms,
        room
      })
    })
  }


}

export const counter = new RoomStore()