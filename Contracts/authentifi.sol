pragma solidity ^0.4.22;
pragma experimental ABIEncoderV2;

contract Authentifi {
    address owner;
    struct codeObj {
        uint status;
        string brand;
        string model;
        string description;
        string manufactuerName;
        string manufactuerLocation;
        string manufactuerTimestamp;
        string retailer;
        string[] customers;
    }
    struct customerObj {
        string name;
        string phone;
        string[] code;
        bool isValue;
    }
    struct retailerObj {
        string name;
        string location;
    }

    mapping (string => codeObj) codeArr;
    mapping (string => customerObj) customerArr;
    mapping (string => retailerObj) retailerArr;

}
