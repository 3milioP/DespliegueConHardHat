const HARDHAT_URL = "http://127.0.0.1:8545";
const DAO_ADDRESS_LOCALHOST = "0x5fbdb2315678afecb367f032d93f642f64180aa3"
const DAO_ADDRESS_TESTNET = ""
const SIGNER_PRIVATEKEY = "0xdf57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e"

const initializeMetamask = async () => {
    let signer = null;

    let provider;
    if (window.ethereum == null) {

        // If MetaMask is not installed, we use the default provider,
        // which is backed by a variety of third-party services (such
        // as INFURA). They do not have private keys installed,
        // so they only have read-only access
        console.log("MetaMask not installed; using read-only defaults")
        provider = ethers.getDefaultProvider()

    } else {

        // Connect to the MetaMask EIP-1193 object. This is a standard
        // protocol that allows Ethers access to make all read-only
        // requests through MetaMask.
        provider = new ethers.BrowserProvider(window.ethereum)

        // It also provides an opportunity to request access to write
        // operations, which will be performed by the private key
        // that MetaMask manages for the user.
        signer = await provider.getSigner();

        return {provider, signer}
    }
}

const initializeContract = async () => {
    const response = await fetch('../../artifacts/contracts/DAO.sol/KeepCodingDAO.json')
    const data = await response.json()

    //provider
    //const provider = new ethers.JsonRpcProvider(HARDHAT_URL)

    const {provider, signer} = await  initializeMetamask() //Alternativa para conexión con Metamask, utilizado para la tesnet

    //read contract
    const readContract = new ethers.Contract(DAO_ADDRESS_LOCALHOST, data.abi, provider)
    //signer
    //const signer = new ethers.Wallet(SIGNER_PRIVATEKEY, provider)

    //write contract
    const writeContract = readContract.connect(signer)
    //return provider, signer, write contract, read contract
    return {provider, signer, writeContract, readContract}
}

const createProposal = async (title, desc, options) => {
   const {writeContract} = await initializeContract()
   await writeContract.createProposal(title, desc, options)
}

const getProposalInfo = async (proposalId) => {
    const {readContract} = await initializeContract()
    await readContract.getProposalInfo(proposalId)
}

const voteProposal = async (proposalId, vote) => {
    const {writeContract} = await initializeContract()
    await writeContract.voteProposal(proposalId, vote)
}

const executeProposal = async (proposalId) => {
    const {writeContract} = await initializeContract()
    await writeContract.executeProposal(proposalId)
}

//Conexion con la interfaz
const createTitleInput = document.getElementById("createTitleInput")
const createDescInput = document.getElementById("createDescInput")
const createOptionsInput = document.getElementById("createOptionsInput")
const getInput = document.getElementById("getInput")
const voteIdInput = document.getElementById("voteIdInput")
const voteOptionInput = document.getElementById("voteOptionInput")
const executeInput = document.getElementById("executeInput")

const createButton = document.getElementById("createButton")
const getButton = document.getElementById("getButton")
const voteButton = document.getElementById("voteButton")
const executeButton = document.getElementById("executeButton")

createButton.addEventListener("click", async () => {
    await createProposal(
        createTitleInput.value,
        createDescInput.value,
        createOptionsInput.value.split(",")
    )
})

getButton.addEventListener("click", async () => {
    const response = await getProposalInfo(
        getInput.value
    )
    console.log(response)
})

voteButton.addEventListener("click", async () => {
        await voteProposal(
            voteIdInput.value,
            voteOptionInput.value
        )
})

executeButton.addEventListener("click", async () => {
    await executeProposal(
        executeInput.value
    )
})
