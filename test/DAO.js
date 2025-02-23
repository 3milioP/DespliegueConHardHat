const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");

  const hre = require("hardhat")

  describe("DAO Test Suite", function(){

    const proposalTitle = "Titulo"
    const proposalDesc = "Descripcion"
    const proposalOptions = ["A","B","C"]

    async function deployDAOFixture(){
        const [owner, otherAccount] = await hre.ethers.getSigners()
        const DAO = await hre.ethers.getContractFactory("KeepCodingDAO")
        const dao = await DAO.deploy()
        await dao.createProposal(proposalTitle, proposalDesc, proposalOptions)
        return {dao, owner, otherAccount}
    }

    describe("Create Proposal", function(){

        it("Should crete proposal", async function(){
            const {dao, owner} = await loadFixture(deployDAOFixture)
            const proposal = await dao.proposals(1)
            expect(proposal.title).to.equal(proposalTitle)
            expect(proposal.description).to.equal(proposalDesc)
            expect(proposal.creator).to.equal(owner)
            expect(proposal.executed).to.be.false
            expect(proposal.optionsNumber).to.equal(proposalOptions.length)
        })
    })

    describe("Get Proposal Info", function(){

        it("Should get the proposal properly", async function(){
            const {dao} = await loadFixture(deployDAOFixture)
            const proposalInfo = await dao.getProposalInfo(1)
            expect(proposalInfo.optionsText.length).to.equal(proposalOptions.length)
            expect(proposalInfo.optionsVotes.length).to.equal(proposalOptions.length)
            for(let i = 0; i < proposalOptions.length; i++){
                expect(proposalInfo.optionsText[i]).to.equal(proposalOptions[i])
                expect(proposalInfo.optionsVotes[i]).to.equal(0)
            }
        })

        it("Should revert when the proposal does not exist", async function(){
            const {dao} = await loadFixture(deployDAOFixture)
            await expect(dao.getProposalInfo(2)).to.be.revertedWithCustomError(
                dao,
                'ProposalDoesNotExist'
            ) 
        })
    })

    describe("Vote Proposal", function(){

        //el 0 significa que estoy votando a la posicion 0, es decir, "A"
        const vote = 0

        it("Should vote the proposal properly", async function(){
            const {dao, owner} = await loadFixture(deployDAOFixture)
            await dao.voteProposal(1, vote) 
            const proposal = await dao.proposals(1)
            const proposalInfo = await dao.getProposalInfo(1)
            expect(proposalInfo.optionsVotes[vote]).to.equal(1)
            expect(await dao.hasAddressVoted(1, owner)).to.be.true

        })

        it("Should revert when the proposal does not exist", async function(){
            const {dao} = await loadFixture(deployDAOFixture)
            await expect(dao.voteProposal(2, vote)).to.be.revertedWithCustomError(
                dao,
                'ProposalDoesNotExist'
            )
        })

        it("Should revert when the proposal is not active", async function(){
            const {dao} = await loadFixture(deployDAOFixture)
            await time.increase(30 * 60)
            await expect(dao.voteProposal(1, vote)).to.be.revertedWithCustomError(
                dao,
                'ProposalDeadlineExceeded'
            )
        })
    })

    describe("Execute Proposal", function(){
        it("Should execute the proposal properly", async function(){
            const {dao, owner} = await loadFixture(deployDAOFixture)
            await time.increase(30 * 60)
            let proposal = await dao.proposals(1)
            expect(proposal.executed).to.be.false
            await dao.executeProposal(1)
            proposal = await dao.proposals(1)
            expect(proposal.executed).to.be.true
        })

        it("Should revert when the proposal does not exist", async function(){
            const {dao} = await loadFixture(deployDAOFixture);
            await expect(dao.executeProposal(2)).to.be.revertedWithCustomError(
                dao,
                'ProposalDoesNotExist'
            )
        })

        it("Should revert when the proposal cannot be executed", async function(){
            const {dao} = await loadFixture(deployDAOFixture);
            await expect(dao.executeProposal(1)).to.be.revertedWithCustomError(
                dao,
                'ProposalCannotBeExecuted'
            )
        })
    })
  })