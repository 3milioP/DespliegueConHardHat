// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface Proposal {
    //Struct utilizado para crear y almacenar la informacion de cada propuesta
    struct MultipleChoiceProposal{
        uint256 proposalId;
        string title;
        string description;
        address creator;
        mapping(address => bool) voters;
        uint256 deadline;
        bool executed;

        //Relaciona cada identificador de opcion con el texto de la opcion.
        mapping(uint8 => string) optionsText;
        //Relaciona cada identificador de opcion con el numero de votos.
        mapping(uint8 => uint8) optionsVotes; //A - B - C se actualiza
        //numero total de opciones que tiene la propuesta
        uint8 optionsNumber;
    }

    //Struct utilizado para devolver la informacion de la propuesta
    //Concretamente, las opciones de la propuesta y su numero de votos
    struct MultipleChoiceProposalInfo{
        string[] optionsText;
        uint8[] optionsVotes;
    }

}