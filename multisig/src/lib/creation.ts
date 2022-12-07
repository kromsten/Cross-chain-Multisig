import gun from "./gun";
import { writable, type Writable } from 'svelte/store'

type Participant = {
    publicKey: string;
    signature: any;
}


type CreationData = {
    participants: Participant[],
    selected: number[],
}


type Selection = {
  signer: Participant,
  selected: number,
}

const DefaultCreationData : CreationData = {
    participants: [], selected: []
}


const validSignature = (newPart : Participant) : boolean => {
    return true;
}


class Creation {
  private readonly name: string = "multisig_creation";
  private readonly newParticipant: string = "new_participant";
  private readonly newSelection: string = "new_selection";

  private dataStore: Writable<CreationData>;
  private selectionStore: Writable<number[]>;

  private data : CreationData;
  private selected : number[]

  constructor() {

    this.dataStore = writable(DefaultCreationData);
    this.selectionStore = writable([]);

    this.data = DefaultCreationData;
    this.selected = [];

    this.dataStore.subscribe(data => {
      this.data = data
    })
    this.selectionStore.subscribe(data => {
      this.selected = data;
    })
    

    const got = gun.get(this.name)

    got.get(this.newParticipant).on((newPart : Participant, key : string) => {
       
      if (!this.signExists(newPart) && validSignature(newPart)) {
        this.dataStore.set({
            ...this.data, 
            participants: [
                ...this.data.participants,
                newPart
            ]
        })
      }
    })

    got.get(this.newSelection).on((selection : Selection, key : string) => {
       
      if (this.data.participants[0].publicKey == selection.signer.publicKey 
        && validSignature(selection.signer)) {
        
      }
    })


  }

  subscribe(callBack : (val : any) => void) {
    return this.dataStore.subscribe(callBack)
  } 

  set(value : any) {
    gun.get(this.name).get('value').put(value)
    return this.dataStore.set(value)
  }

  signExists(part : Participant)  {
    return this.data.participants
            .findIndex(p => p.publicKey === part.publicKey) !== -1
  }
}

export const counter = new Creation()