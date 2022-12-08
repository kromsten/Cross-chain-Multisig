import gun from "./gun";
import { writable, type Writable } from 'svelte/store'


type Participant = {
    publicKey: string;
    signature: any;
}


type CreationData = {
    lurkers: any[]; 
    participants: Participant[],
    selected: number[],
}

type Selections = {
  selections: number[];
  from: Participant
}

type Presence = {
  id : string,
  present: boolean
}


const DefaultCreationData : CreationData = {
  lurkers: [], participants: [], selected: []
}


const validSignature = (newPart : Participant) : boolean => {
    return true;
}





class Creation {
  private readonly name: string = "wabadubadums";
  
  private readonly participants: string = "participantss";
  private readonly selections: string = "selectionss";


  private dataStore: Writable<CreationData>;

  private data : CreationData;

  constructor() {

    this.dataStore = writable(DefaultCreationData);

    this.data = DefaultCreationData;

    this.dataStore.subscribe(data => {
      this.data = data
    })
    

    const got = gun.get(this.name)



    got.get(this.participants).map((newPart : Participant) => {   

      console.log("got part:", newPart);


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


    got.get(this.selections).map((data: Selections) => {
      if (this.data.participants[0].publicKey == data.from.publicKey 
        && validSignature(data.from)) {
        this.dataStore.set({
          ...this.data, 
          selected: data.selections
        })
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





  private registerLurkers (presence : any) {  
      
    console.log("got presence:", presence);

    console.log("conditions::", !this.data.lurkers.includes(presence.id), presence.present);


    if (!this.data.lurkers.includes(presence.id) && presence.present) {

      console.log("about to add new presence:")


      const newData = {...this.data, 
        lurkers: [
            ...this.data.lurkers,
            presence.id
        ]};

      this.dataStore.set({
          ...this.data, 
          lurkers: [
              ...this.data.lurkers,
              presence.id
          ]
      })

      console.log("supposed to be added now", newData)



    } else if (!presence.present) {

      this.dataStore.set({
        ...this.data, 
          lurkers: this.data.lurkers.filter(id => presence.id !== id)
      })

    }

  }
}


const creationStore = new Creation()
export default creationStore