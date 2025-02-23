// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

//Imports
import {Proposal} from  "./Proposal.sol";
import {Counter} from "./Counter.sol";
import "hardhat/console.sol";

/**
 * @title  EmilioDAO (Decentralized Autonomous Organization)
 * @author Emilio Pérez Arjona
 * @notice DAO que permite la creación de propuestas de tipo multiple choice.
 * @dev    Implementa la interfaz IProposal y Counter.
 */
contract KeepCodingDAO is Proposal, Counter {



    /**
     * -----------------------------------------------------------------------------------------------------
     *                                      ATRIBUTOS
     * -----------------------------------------------------------------------------------------------------
     */

     mapping(uint256 => MultipleChoiceProposal) public proposals;

    /**
     * -----------------------------------------------------------------------------------------------------
     *                                      CONSTRUCTOR
     * -----------------------------------------------------------------------------------------------------
     */

     constructor() Counter(0){

     }

    /**
     * -----------------------------------------------------------------------------------------------------
     *                                      ERRORS
     * -----------------------------------------------------------------------------------------------------
     */

     error ProposalDoesNotExist(uint256 _proposalIdConsultado);
     error ProposalDeadlineExceeded(uint256 _proposalId);
     error ProposalCannotBeExecuted(uint256 _proposalId);


    /**
     * -----------------------------------------------------------------------------------------------------
     *                                      MODIFIERS
     * -----------------------------------------------------------------------------------------------------
     */

    /**
        Comprueba si la propuesta existe.
        Si no existe lanza el error ProposalDoesNotExist.
     */
     modifier doesProposalExist(uint256 _proposalId){
        if(proposals[_proposalId].optionsNumber == 0){
            revert ProposalDoesNotExist(_proposalId);
        }
        _;
    }


    /**
        Comprueba si la propuesta esta activa.
        Si no esta activa lanza el error ProposalDeadlineExceeded.
        Ejemplo: Si el bloque actual es mayor que el deadline de la propuesta, la propuesta ha expirado, ya no se puede votar.
     */
     modifier isProposalActive(uint256 _proposalId){
        if(block.timestamp > proposals[_proposalId].deadline){
            revert ProposalDeadlineExceeded(_proposalId);
        }
        _;
    }

    /**
        Comprueba si la propuesta ha superado su deadline y puede ser ejecutada.
        Si no lo ha superado lanza el error ProposalCannotBeExecuted.
        EJemplo: Si el bloque actual es menor que el deadline de la propuesta, la propuesta no puede ser ejecutada porque aún no ha expirado el tiempo de votación.
     */
    modifier canProposalBeExecuted(uint256 _proposalId){
        if(block.timestamp < proposals[_proposalId].deadline){
            revert ProposalCannotBeExecuted(_proposalId);
        }
        _;
    }

    /**
     * -----------------------------------------------------------------------------------------------------
     *                                      EVENTS
     * -----------------------------------------------------------------------------------------------------
     */

     event ProposalCreated(uint256 _proposalId, address indexed _creator);
     event ProposalVoted(uint256 indexed _proposalId, address indexed _voter);
     event ProposalExecuted(uint256 _proposalId);
     

    /**
     * -----------------------------------------------------------------------------------------------------
     *                                      FUNCIONES
     * -----------------------------------------------------------------------------------------------------
     */

    /**
        Crea una propuesta e inicializa sus datos
     */
    function createProposal(string memory _title, string memory _description, string[] memory _options) public{
        //obtener el id
        uint256 proposalId = increment();
        //crear el objeto proposal
        MultipleChoiceProposal storage proposal = proposals[proposalId];
        //rellenar el id
        proposal.proposalId = proposalId;
        //rellenar el titulo
        proposal.title = _title;
        //rellenar la descriocion
        proposal.description = _description;
        //rellenar el creador
        proposal.creator = msg.sender;
        //proposal.voters no hay que hacer nada en creacion
        //rellenar el deadline - 30 minutos 
        proposal.deadline = block.timestamp + 30 minutes;
        //inicializar el executed
        proposal.executed = false;
        //iterar sobre el array de opciones para rellenar los mappings. Pista usar _options.length
        for(uint8 i = 0; i < _options.length; i++){
            //inicializar las opciones
            proposal.optionsText[i] = _options[i];
            //inicializar los votos
            proposal.optionsVotes[i] = 0;
        }
        //inicializar el numero de opciones de la propuesta
        proposal.optionsNumber = uint8(_options.length);
        //emitir evento ProposalCreated
        emit ProposalCreated(proposalId, msg.sender);
    }

    
    /**
        Obtiene informacion de la propuesta relativa a las opciones y sus votos.
        Rellena y devuelve un objeto MultipleChoiceProposalInfo.
        La propuesta debe existir.
     */
    function getProposalInfo(uint256 _proposalId) doesProposalExist(_proposalId) public view returns(MultipleChoiceProposalInfo memory){
        //obtener la propuesta cuyo id es el parametro recibido
        MultipleChoiceProposal storage selectedProposal = proposals[_proposalId];
        //inicializar el objeto MultipleChoiceProposalInfo. Pista no es necesario usar storage, mejor usar memory
        MultipleChoiceProposalInfo memory proposalInfo = MultipleChoiceProposalInfo({
            //inicializar el array optionsText dentro del struct
            optionsText: new string[](selectedProposal.optionsNumber),
            //inicializar el array optionsVotes dentro del struct
            optionsVotes: new uint8[](selectedProposal.optionsNumber)
        });

        //iterar sobre las opciones. Pista usar el campo optionsNumber como tope del bucle
        for(uint8 i = 0; i < proposals[_proposalId].optionsNumber; i++){
            //coger el optionsText
            proposalInfo.optionsText[i] = proposals[_proposalId].optionsText[i];
            //coger el optionsVotes
            proposalInfo.optionsVotes[i] = proposals[_proposalId].optionsVotes[i];
        }
        //devolver el objeto MultipleChoiceProposalInfo

        console.log("Fetching Proposal ID: %s", _proposalId);
        console.log("Options Number: %s", selectedProposal.optionsNumber);
        for(uint8 i = 0; i < selectedProposal.optionsNumber; i++) {
            console.log("Option %s: %s - Votes: %s", i, selectedProposal.optionsText[i], selectedProposal.optionsVotes[i]);
        }
        return proposalInfo;
    }



    /**
        Funcion que permite emitir un voto sobre una propuesta.
        Recibe el id de la propuesta y el codigo de la opcion.
        La propuesta debe existir y estar activa.
     */
    function voteProposal(uint256 _proposalId, uint8 _optionCode) public doesProposalExist(_proposalId) isProposalActive(_proposalId){
        // Verificar si la dirección ya votó
        if (hasAddressVoted(_proposalId, msg.sender)) {
        revert("You have already voted on this proposal");
        }
        //sumar el voto a su opcion
        proposals[_proposalId].optionsVotes[_optionCode]++;
        //incluir el address como que ya voto
        proposals[_proposalId].voters[msg.sender] = true;
        //emitir el evento ProposalVoted
        emit ProposalVoted(_proposalId, msg.sender);
    } 

    /**
        Comrpueba si una address concreta ha votado en una propuesta concreta.
        Recibe el id de la propuesta y el address que va a ser comprobado.
        La propuesta debe existir.
     */
    function hasAddressVoted(uint256 _proposalId, address _address) public view doesProposalExist(_proposalId) returns (bool){
        return proposals[_proposalId].voters[_address];
    }

    /**
        Funcion que ejecuta una propuesta.
        Para que una funcion pueda ser ejecutada tiene que haberse superado el deadline.
        La propuesta debe existir y la deadline haberse superado.
     */
    function executeProposal(uint256 _proposalId) public doesProposalExist(_proposalId) canProposalBeExecuted(_proposalId){
        //establecer la propuesta como ejecutada
        proposals[_proposalId].executed = true;
        //emitir el evento ProposalExecuted
        emit ProposalExecuted(_proposalId);
    }       

}