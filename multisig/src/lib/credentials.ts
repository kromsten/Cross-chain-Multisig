import { v4 as uuidv4 } from 'uuid';



const getId = () : string => {

    if (typeof window === 'undefined') {
        const id = uuidv4()

        setTimeout(() => {
            if (typeof window !== 'undefined') {
                localStorage.setItem("multisig_id", id)
            }
        }, 2000)

        return id
    }

    const exist =  localStorage.getItem("multisig_id");
    if (exist) { return exist }
    else {
        const id = uuidv4()
        localStorage.setItem("multisig_id", id)
        return id
    }
}


export default getId;
