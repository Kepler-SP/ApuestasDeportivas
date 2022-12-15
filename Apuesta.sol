// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

pragma experimental ABIEncoderV2;

contract Apuesta {
    address contrato;
    MiCuenta contratoMiCuenta;

    uint256 fondoTotal_A = 30540;
    uint256 fondoTotal_B = 91800;
    uint256 dinero_apostado = 115; /// En dolares

    constructor() {
        contrato = payable(address(this));
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

    //todo: Funciones para calcular el porcentaje de ganancias
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

    //todo: Transferencia del dinero
    //* Transferencia de las ganancias de acuerdo a su porcentaje de aporte
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

    //todo: Funciones de apoyo
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

    function compareStrings(
        string memory a,
        string memory b
    ) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    //todo: PARTE 2
    struct Encuentros {
        mapping (string => uint) team_1;
        mapping (string => uint) team_2;
        uint8 ganador; /// '1' o '2'
    }

    /// Creamos un array de Encuentros
    Encuentros[] public arrayEncuentros;

    /// Solo ejecutada por el owner
    function agregarEquipos(string memory _team1, string memory _team2) public {
        //? mapping (string => uint) memory name;  
        arrayEncuentros.push(Encuentros({team_1:name  , team_2:name , ganador: 0}));
    }

    /// Mapping para relacionar [usuario][su_contrato]
    mapping(address => address) usuario_cuenta;

    function getContract(address _usuario) private {
        address contractUser = address(new MiCuenta(_usuario, address(this)));
        usuario_cuenta[_usuario] = contractUser;
    }

    //La cantidad será pasada en dolares pero se pagará el msg.value con weis
    function apostar(
        uint8 _encuentro,
        string memory _pronostico,
        uint256 _cantidad
    ) external payable {
        if (usuario_cuenta[msg.sender] == address(0)) {
            getContract(msg.sender);
        }

        /// Comprobar que tenga el dinero
        require(
            msg.value >= dolar_weis(_cantidad),
            "Las cantidades a pagar no coinciden"
        );

        /// Comprobar que el equipo exista
        Encuentros memory encuentro = arrayEncuentros[_encuentro];
        require(
            compareStrings(encuentro.team_1, _pronostico) ||
                compareStrings(encuentro.team_2, _pronostico),
            "El equipo no existe"
        );

        /// Obteniendo una intancia del contrato del usuario
        contratoMiCuenta = MiCuenta(usuario_cuenta[msg.sender]);
        contratoMiCuenta.actMap(_encuentro, _cantidad);

        /// Realizamos la transferencia del dinero al smart contract
        (bool sent, ) = address(this).call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    function consultarResultado(uint8 _numEncuentro) public view returns (uint8) {
        Encuentros memory encuentro = arrayEncuentros[_numEncuentro];
        return encuentro.ganador;
    }
}

contract MiCuenta {
    Apuesta miApuesta;

    struct Profile {
        address owner;
        address padre;
        uint apuestasRealizadas; /// Para acceder al mapping
    }
    Profile perfil;

    mapping(uint8 => uint256) teamMoney;

    constructor(address _owner, address _padre) {
        perfil.owner = _owner;
        perfil.padre = _padre;
        miApuesta = Apuesta(perfil.padre);
    }

    function realizarApuesta(
        uint8 _encuentro,
        string memory _pronostico,
        uint256 _cantidad
    ) public {
        /// Confirmar que tenga el dinero
        /// Verificar que el equipo exista
        miApuesta.apostar(_encuentro, _pronostico, _cantidad);
        perfil.apuestasRealizadas += 1;
    }

    function retirarGanancias() public {
        /// Verificar el ganador del partido -> funcion del contrato padre

        perfil.apuestasRealizadas = 0;
    }

    function actMap(uint8 _group, uint _cant) external {
        teamMoney[_group] = _cant;
    }
}
