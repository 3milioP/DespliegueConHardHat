// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

//Imports

/**
 * @title  Counter
 * @author Emilio Pérez Arjona
 * @notice Contrato que implementa un contador.
 * @dev    Implementa un contador que se incrementa en una unidad cada vez que se llama a la funcion increment.
 */
contract Counter {

    /**
     * -----------------------------------------------------------------------------------------------------
     *                                      ATRIBUTOS
     * -----------------------------------------------------------------------------------------------------
     */

     uint256 private counter;

    /**
     * -----------------------------------------------------------------------------------------------------
     *                                      CONSTRUCTOR
     * -----------------------------------------------------------------------------------------------------
     */
     constructor(uint256 _initialValue){
        counter = _initialValue;
     }

    /**
     * -----------------------------------------------------------------------------------------------------
     *                                      ERRORS
     * -----------------------------------------------------------------------------------------------------
     */

    /**
     * Los errores son lanzados mediante la instruccion revert, normalmente despues de comprobar una condicion.
     * El nombre del error explica cual es el motivo por el se ha revertido la transaccion. 
     * Para mas informacion, buscar la condicion en la que se lanza el error.
     */

    /**
     * -----------------------------------------------------------------------------------------------------
     *                                      MODIFIERS
     * -----------------------------------------------------------------------------------------------------
     */

    /**
     * -----------------------------------------------------------------------------------------------------
     *                                      EVENTS
     * -----------------------------------------------------------------------------------------------------
     */

     event Increment(uint256 _value, address indexed _by);
     

    /**
     * -----------------------------------------------------------------------------------------------------
     *                                      FUNCIONES
     * -----------------------------------------------------------------------------------------------------
     */

    function increment() public returns(uint256){
        counter++;
        emit Increment(counter, msg.sender);
        return counter;
    }

    //todo: queremos una funcion que lea el valor actual de nuestro contrador
    function getCounterValue() public view returns(uint256) {
        return counter;
    }

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
}