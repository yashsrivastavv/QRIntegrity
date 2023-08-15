// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

contract Authentifi {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    struct Code {
        uint256 status;
        string brand;
        string model;
        string description;
        string manufacturerName;
        string manufacturerLocation;
        string manufacturerTimestamp;
        string retailer;
        string[] customers;
    }

    struct Customer {
        string name;
        string phone;
        string[] codes;
        bool isValue;
    }

    struct Retailer {
        string name;
        string location;
    }

    mapping (string => Code) public codeArr;
    mapping (string => Customer) public customerArr;
    mapping (string => Retailer) public retailerArr;

    function createCode(
        string memory _code,
        string memory _brand,
        string memory _model,
        uint256 _status,
        string memory _description,
        string memory _manufacturerName,
        string memory _manufacturerLocation,
        string memory _manufacturerTimestamp
    ) public returns (uint) {
        Code memory newCode;
        newCode.brand = _brand;
        newCode.model = _model;
        newCode.status = _status;
        newCode.description = _description;
        newCode.manufacturerName = _manufacturerName;
        newCode.manufacturerLocation = _manufacturerLocation;
        newCode.manufacturerTimestamp = _manufacturerTimestamp;
        codeArr[_code] = newCode;
        return 1;
    }

    function getNotOwnedCodeDetails(string memory _code) public view returns (
        string memory, string memory, uint256, string memory, string memory, string memory, string memory
    ) {
        Code memory code = codeArr[_code];
        return (
            code.brand, code.model, code.status, code.description,
            code.manufacturerName, code.manufacturerLocation, code.manufacturerTimestamp
        );
    }

    function getOwnedCodeDetails(string memory _code) public view returns (
        string memory, string memory
    ) {
        Retailer memory retailer = retailerArr[codeArr[_code].retailer];
        return (retailer.name, retailer.location);
    }

    function addRetailerToCode(string memory _code, string memory _hashedEmailRetailer) public returns (uint) {
        codeArr[_code].retailer = _hashedEmailRetailer;
        return 1;
    }

    function createCustomer(string memory _hashedEmail, string memory _name, string memory _phone) public returns (bool) {
        if (customerArr[_hashedEmail].isValue) {
            return false;
        }
        Customer memory newCustomer;
        newCustomer.name = _name;
        newCustomer.phone = _phone;
        newCustomer.isValue = true;
        customerArr[_hashedEmail] = newCustomer;
        return true;
    }

    function getCustomerDetails(string memory _code) public view returns (string memory, string memory) {
        Customer memory customer = customerArr[_code];
        return (customer.name, customer.phone);
    }

    function createRetailer(string memory _hashedEmail, string memory _retailerName, string memory _retailerLocation) public returns (uint) {
        Retailer memory newRetailer;
        newRetailer.name = _retailerName;
        newRetailer.location = _retailerLocation;
        retailerArr[_hashedEmail] = newRetailer;
        return 1;
    }

    function getRetailerDetails(string memory _code) public view returns (string memory, string memory) {
        Retailer memory retailer = retailerArr[_code];
        return (retailer.name, retailer.location);
    }

    function reportStolen(string memory _code, string memory _customer) public returns (bool) {
        if (customerArr[_customer].isValue) {
            for (uint256 i = 0; i < customerArr[_customer].codes.length; i++) {
                if (compareStrings(customerArr[_customer].codes[i], _code)) {
                    codeArr[_code].status = 2;
                    return true;
                }
            }
        }
        return false;
    }

    function changeOwner(
        string memory _code,
        string memory _oldCustomer,
        string memory _newCustomer
    ) public returns (bool) {
        Customer storage oldCustomer = customerArr[_oldCustomer];
        Customer storage newCustomer = customerArr[_newCustomer];

        if (oldCustomer.isValue && newCustomer.isValue) {
            for (uint256 i = 0; i < oldCustomer.codes.length; i++) {
                if (compareStrings(oldCustomer.codes[i], _code)) {
                    // Update the customer's codes
                    oldCustomer.codes[i] = newCustomer.codes[newCustomer.codes.length - 1];
                    newCustomer.codes.pop();

                    // Update code's customers
                    Code storage code = codeArr[_code];
                    for (uint256 j = 0; j < code.customers.length; j++) {
                        if (compareStrings(code.customers[j], _oldCustomer)) {
                            code.customers[j] = _newCustomer;
                            return true;
                        }
                    }
                }
            }
        }
        return false;
    }

    function initialOwner(string memory _code, string memory _retailer, string memory _customer) public returns(bool) {
        if (compareStrings(codeArr[_code].retailer, _retailer) && customerArr[_customer].isValue) {
            codeArr[_code].customers.push(_customer);
            codeArr[_code].status = 1;

            customerArr[_customer].codes.push(_code);
            return true;
        }
        return false;
    }

    function getCodes(string memory _customer) public view returns (string[] memory) {
        return customerArr[_customer].codes;
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}