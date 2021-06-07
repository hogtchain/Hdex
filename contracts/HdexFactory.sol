pragma solidity =0.5.16;

import './interfaces/IHdexFactory.sol';
import './interfaces/IHdexPair.sol';
import './interfaces/IHdexERC20.sol';
import './interfaces/IERC20.sol';
import './interfaces/IHdexCallee.sol';

import './HdexERC20.sol';
import './HdexPair.sol';

import './libraries/UQ112x112.sol';
import './libraries/SafeMath.sol';
import './libraries/Math.sol';


contract HdexFactory is IHdexFactory {
    address public feeTo;
    address public feeToSetter;

    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(HdexPair).creationCode));

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'Hdex: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'Hdex: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'Hdex: PAIR_EXISTS');
        bytes memory bytecode = type(HdexPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IHdexPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'Hdex: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'Hdex: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}

