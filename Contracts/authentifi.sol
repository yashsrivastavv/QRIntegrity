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

    function createCode(string _code, string _brand, string _model, uint _status, string _description, string _manufactuerName, string _manufactuerLocation, string _manufactuerTimestamp) public payable returns (uint) {
        codeObj newCode;
        newCode.brand = _brand;
        newCode.model = _model;
        newCode.status = _status;
        newCode.description = _description;
        newCode.manufactuerName = _manufactuerName;
        newCode.manufactuerLocation = _manufactuerLocation;
        newCode.manufactuerTimestamp = _manufactuerTimestamp;
        codeArr[_code] = newCode;
        return 1;
    }
    function getNotOwnedCodeDetails(string _code) public view returns (string, string, uint, string, string, string, string) {
        return (codeArr[_code].brand, codeArr[_code].model, codeArr[_code].status, codeArr[_code].description, codeArr[_code].manufactuerName, codeArr[_code].manufactuerLocation, codeArr[_code].manufactuerTimestamp);
    }
    function getOwnedCodeDetails(string _code) public view returns (string, string) {
        return (retailerArr[codeArr[_code].retailer].name, retailerArr[codeArr[_code].retailer].location);
    }
    function addRetailerToCode(string _code, string _hashedEmailRetailer) public payable returns (uint) {
        codeArr[_code].retailer = _hashedEmailRetailer;
        return 1;
    }
    function createCustomer(string _hashedEmail, string _name, string _phone) public payable returns (bool) {
        if (customerArr[_hashedEmail].isValue) {
            return false;
        }
        customerObj newCustomer;
        newCustomer.name = _name;
        newCustomer.phone = _phone;
        newCustomer.isValue = true;
        customerArr[_hashedEmail] = newCustomer;
        return true;
    }
    function getCustomerDetails(string _code) public view returns (string, string) {
        return (customerArr[_code].name, customerArr[_code].phone);
    }function createRetailer(string _hashedEmail, string _retailerName, string _retailerLocation) public payable returns (uint) {
        retailerObj newRetailer;
        newRetailer.name = _retailerName;
        newRetailer.location = _retailerLocation;
        retailerArr[_hashedEmail] = newRetailer;
        return 1;
    }
    function getRetailerDetails(string _code) public view returns (string, string) {
        return (retailerArr[_code].name, retailerArr[_code].location);
    }
    function reportStolen(string _code, string _customer) public payable returns (bool) {
        uint i;
        // Checking if the customer exists
        if (customerArr[_customer].isValue) {
            // Checking if the customer owns the product
            for (i = 0; i < customerArr[_customer].code.length; i++) {
                if (compareStrings(customerArr[_customer].code[i], _code)) {
                    codeArr[_code].status = 2;        // Changing the status to stolen
                }
                return true;
            }
        }
        return false;
    }
    function changeOwner(string _code, string _oldCustomer, string _newCustomer) public payable returns (bool) {
        uint i;
        bool flag = false;
         //Creating objects for code,oldCustomer,newCustomer
        codeObj memory product = codeArr[_code];
        uint len_product_customer = product.customers.length;
        customerObj memory oldCustomer = customerArr[_oldCustomer];
        uint len_oldCustomer_code = customerArr[_oldCustomer].code.length;
        customerObj memory newCustomer = customerArr[_newCustomer];

        //Check if oldCustomer and newCustomer have an account
        if (oldCustomer.isValue && newCustomer.isValue) {
            //Check if oldCustomer is owner
            for (i = 0; i < len_oldCustomer_code; i++) {
                if (compareStrings(oldCustomer.code[i], _code)) {
                    flag = true;
                    break;
                }
            }

            if (flag == true) {
                //Swaping oldCustomer with newCustomer in product
                for (i = 0; i < len_product_customer; i++) {
                    if (compareStrings(product.customers[i], _oldCustomer)) {
                        codeArr[_code].customers[i] = _newCustomer;
                        break;
                    }
                }

                // Removing product from oldCustomer
                for (i = 0; i < len_oldCustomer_code; i++) {
                    if (compareStrings(customerArr[_oldCustomer].code[i], _code)) {
                        remove(i, customerArr[_oldCustomer].code);
                        // Adding product to newCustomer
                        uint len = customerArr[_newCustomer].code.length;
                        if(len == 0){
                            customerArr[_newCustomer].code.push(_code);
                            customerArr[_newCustomer].code.push("hack");
                        } else {
                            customerArr[_newCustomer].code[len-1] = _code;
                            customerArr[_newCustomer].code.push("hack");
                        }
                        return true;
                    }
                }
            }
        }
        return false;
    }


    function initialOwner(string _code, string _retailer, string _customer) public payable returns(bool) {
            uint i;
            if (compareStrings(codeArr[_code].retailer, _retailer)) {       // Check if retailer owns the prodct
                if (customerArr[_customer].isValue) {                       // Check if Customer has an account
                    codeArr[_code].customers.push(_customer);               // Adding customer in code
                    codeArr[_code].status = 1;
                    uint len = customerArr[_customer].code.length;
                    if(len == 0) {
                        customerArr[_customer].code.push(_code);
                        customerArr[_customer].code.push("hack");
                    } else {
                    customerArr[_customer].code[len-1] = _code;
                    customerArr[_customer].code.push("hack");
                    }
                    return true;
                }
            }
            return false;
        }

    function getCodes(string _customer) public view returns(string[]) {
        return customerArr[_customer].code;
    }

    function compareStrings(string a, string b) internal returns (bool) {
    	return keccak256(a) == keccak256(b);
    }

    function remove(uint index, string[] storage array) internal returns(bool) {
        if (index >= array.length)
            return false;

        for (uint i = index; i < array.length-1; i++) {
            array[i] = array[i+1];
        }
        delete array[array.length-1];
        array.length--;
        return true;
    }

    function stringToBytes32(string memory source) internal returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }
}

