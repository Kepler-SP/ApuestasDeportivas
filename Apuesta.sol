// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

pragma experimental ABIEncoderV2;

contract Apuesta {
    uint256 fondoTotal_A = 30540;
    uint256 fondoTotal_B = 91800;
    uint256 dinero_apostado = 115; /// En dolares

    constructor() {
        calcular_mi_porcentaje();
    }

    function calcular_mi_porcentaje() public view {
        // Se calcula con el dinero en dolares
        // (dinero_apostado * 100)/fondoTotal
        // El porcentaje será devuelto en weis
        uint256 numerador = dinero_apostado * 100;
        uint256 decimal_1;
        uint256 decimal_2;
        uint256 decimal_3;
        uint ceros_post_coma = 0;

        if (numerador < fondoTotal_A) {
            while (numerador < fondoTotal_A) {
                numerador *= 10;
                ceros_post_coma += 1;
            }
            dentro_if(
                decimal_1,
                decimal_2,
                decimal_3,
                numerador,
                ceros_post_coma
            );
        } else {
            dentro_else(decimal_1, decimal_2, decimal_3, numerador);
        }
    }

    //* Para operaciones de 0,xyz... ✅
    function dentro_if(
        uint256 decimal_1,
        uint256 decimal_2,
        uint256 decimal_3,
        uint256 numerador,
        uint256 ceros
    ) private view {
        /// Solo me calculará los decimales que no sean 0 a la izquierda (0,00014) -> solo tomará el 14
        decimal_1 = SafeMath.div(numerador, fondoTotal_A);
        uint256 residuo_1 = SafeMath.mod(numerador, fondoTotal_A);

        decimal_2 = SafeMath.div(residuo_1 * 10, fondoTotal_A);
        uint256 residuo_2 = SafeMath.mod(residuo_1 * 10, fondoTotal_A);
        decimal_3 = SafeMath.div(residuo_2 * 10, fondoTotal_A);

        string memory cosa1 = Strings.toString(decimal_1);
        string memory cosa2 = Strings.toString(decimal_2);
        string memory cosa3 = Strings.toString(decimal_3);
        string memory cosa4 = string(abi.encodePacked(cosa1, cosa2, cosa3));

        uint256 num = uint256(stringToUint(cosa4));

        ///Realizamos la transferencia ✅
        ceros -= 1;
        transferirGanancias(0, ceros, num);
    }

    //* Para operaciones x,mnp... ✅
    function dentro_else(
        uint256 decimal_1,
        uint256 decimal_2,
        uint256 decimal_3,
        uint256 numerador
    ) private view {
        /// Hallando los decimales ✅
        uint256 ceros;
        uint256 entero = SafeMath.div(numerador, fondoTotal_A);
        uint256 residuo_1 = SafeMath.mod(numerador, fondoTotal_A);
        uint256 pt_decimal = 0;
        if (residuo_1 == 0) {
            decimal_1 = 0;
            decimal_2 = 0;
            decimal_3 = 0;
            ceros = 0;
        } else {
            while (residuo_1 < fondoTotal_A) {
                residuo_1 *= 10;
                /// N° de ceros luego de la coma
                ceros += 1;
            }
            decimal_1 = SafeMath.div(residuo_1, fondoTotal_A);
            uint256 residuo_2 = SafeMath.mod(residuo_1, fondoTotal_A);

            residuo_2 *= 10;
            decimal_2 = SafeMath.div(residuo_2, fondoTotal_A);

            uint residuo_3 = SafeMath.mod(residuo_2, fondoTotal_A);
            decimal_3 = SafeMath.div(residuo_3 * 10, fondoTotal_A);

            string memory cosa1 = Strings.toString(decimal_1);
            string memory cosa2 = Strings.toString(decimal_2);
            string memory cosa3 = Strings.toString(decimal_3);
            string memory cosa4 = string(abi.encodePacked(cosa1, cosa2, cosa3));

            pt_decimal = uint256(stringToUint(cosa4));
            ceros -= 1;
        }

        ///Realizamos la transferencia ✅
        transferirGanancias(entero, ceros, pt_decimal);
    }

    //* Transferencia de las ganancia de acuerdo a su porcentaje de aporte
    function transferirGanancias(
        uint _entero,
        uint _ceros,
        uint _decimales
    ) private view {
        uint weis_fondoTotal = dolar_weis(fondoTotal_A) +
            dolar_weis(fondoTotal_B);
        /// Ganancia de la parte entera ✅
        uint pt1 = Math.mulDiv(_entero, weis_fondoTotal, 100);

        /// Ganancia de la parte decimal
        if (_decimales % 10 == 0) {
            _ceros += 2;
            if (_decimales % 100 == 0) {
                _ceros -= 1;
            }
        }
        _ceros += 3; /// Cantidad de ceros + digitos de la parte decimal diferentes de 0
        _ceros += 2; /// Le sumamos los ceros del porcentaje (1/100)
        uint pt2 = Math.mulDiv(_decimales, weis_fondoTotal, 10 ** _ceros);
        uint total = pt1 + pt2;

        console.log("PT1: ", pt1);
        console.log("PT2: ", pt2);
        console.log("GANANCIAS POR APOSTAR: ", total);
    }

    function dolar_weis(uint _dolares) private pure returns (uint _weis) {
        /// 1 USD = 781475895376007 weis
        uint usd_weis = 781475895376007; /// Un USD equivale a esta candidad de weis
        uint precio_weis = _dolares * usd_weis;
        return precio_weis;
    }

    function stringToUint(string memory s) private pure returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }
}
