pragma solidity =0.5.16;


interface IHdexCallee {
    function hdexCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}