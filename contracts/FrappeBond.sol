// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.25;

import "@fhenixprotocol/cofhe-contracts/FHE.sol";

interface IERC3475 {
    struct Values { 
        string stringValue;
        uint uintValue;
        address addressValue;
        bool boolValue;
    }

    struct Metadata {
        string title;
        string _type;
        string description;
    }

    struct Transaction {
        uint256 classId;
        uint256 nonceId;
        uint256 _amount;
    }

    function transferFrom(address _from, address _to, Transaction[] calldata _transactions) external;
    function transferAllowanceFrom(address _from, address _to, Transaction[] calldata _transactions) external;
    function issue(address _to, Transaction[] calldata _transactions) external;
    function redeem(address _from, Transaction[] calldata _transactions) external;
    function burn(address _from, Transaction[] calldata _transactions) external;
    function approve(address _spender, Transaction[] calldata _transactions) external;
    function setApprovalFor(address _operator, bool _approved) external;

    function totalSupply(uint256 classId, uint256 nonceId) external view returns (uint256);
    function redeemedSupply(uint256 classId, uint256 nonceId) external view returns (uint256);
    function activeSupply(uint256 classId, uint256 nonceId) external view returns (uint256);
    function burnedSupply(uint256 classId, uint256 nonceId) external view returns (uint256);
    function balanceOf(address _account, uint256 classId, uint256 nonceId) external view returns (uint256);

    function getProgress(uint256 classId, uint256 nonceId)
        external
        view
        returns (uint256 progressAchieved, uint256 progressRemaining);

    function allowance(address _owner, address _spender, uint256 classId, uint256 nonceId)
        external view returns (uint256);

    function isApprovedFor(address _owner, address _operator)
        external view returns (bool);

    event Transfer(address indexed _operator, address indexed _from, address indexed _to, Transaction[] _transactions);
    event Issue(address indexed _operator, address indexed _to, Transaction[] _transactions);
    event Redeem(address indexed _operator, address indexed _from, Transaction[] _transactions);
    event Burn(address indexed _operator, address indexed _from, Transaction[] _transactions);
    event ApprovalFor(address indexed _owner, address indexed _operator, bool _approved);
}

interface IERC3475EXTENSION {
    struct ValuesExtension {
        string stringValue;
        uint uintValue;
        address addressValue;
        bool boolValue;
        string[] stringArrayValue;
        uint[] uintArrayValue;
        address[] addressArrayValue;
        bool[] boolAraryValue;
    }

    function classValuesFromTitle(uint256 _classId, string memory _metadataTitle)
        external view returns (ValuesExtension memory);

    function nonceValuesFromTitle(uint256 _classId, uint256 _nonceId, string memory _metadataTitle)
        external view returns (ValuesExtension memory);

    event classCreated(address indexed _operator, uint256 _classId);
}

contract FrappeBond is IERC3475, IERC3475EXTENSION {

    struct Nonce {
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
        uint256 _activeSupply;
        uint256 _burnedSupply;
        uint256 _redeemedSupply;
    }

    struct Class {
        mapping(uint256 => Nonce) _nonces;
    }

    mapping(address => mapping(address => bool)) _operatorApprovals;
    mapping(uint256 => Class) internal _classes;

    /* ============================================================= */
    /*                   CONFIDENTIAL STORAGE                        */
    /* ============================================================= */

// classId => nonceId => holder => encrypted blob
mapping(uint256 => mapping(uint256 => mapping(address => bytes)))
    private _confidentialData;

/**
 * @notice Store encrypted confidential data
 * @dev Data must already be encrypted off-chain
 */
function setConfidentialData(
    uint256 classId,
    uint256 nonceId,
    bytes calldata encryptedData
) external {
    require(
        balanceOf(msg.sender, classId, nonceId) > 0,
        "Must hold bond"
    );

    _confidentialData[classId][nonceId][msg.sender] = encryptedData;
}

/**
 * @notice Retrieve encrypted confidential data
 */
function getConfidentialData(
    uint256 classId,
    uint256 nonceId
) external view returns (bytes memory) {
    require(
        balanceOf(msg.sender, classId, nonceId) > 0,
        "Must hold bond"
    );

    return _confidentialData[classId][nonceId][msg.sender];
}

    /* ============================================================= */
    /*                    BASIC ERC3475 LOGIC                        */
    /* ============================================================= */

    function balanceOf(
        address account,
        uint256 classId,
        uint256 nonceId
    ) public view override returns (uint256) {
        return _classes[classId]._nonces[nonceId]._balances[account];
    }

    function allowance(
        address _owner,
        address spender,
        uint256 classId,
        uint256 nonceId
    ) public view override returns (uint256) {
        return _classes[classId]._nonces[nonceId]._allowances[_owner][spender];
    }

    function isApprovedFor(
        address _owner,
        address operator
    ) public view override returns (bool) {
        return _operatorApprovals[_owner][operator];
    }

    function getProgress(uint256, uint256)
        public
        pure
        override
        returns (uint256, uint256)
    {
        return (0, 0);
    }

    function totalSupply(uint256, uint256)
        public
        pure
        override
        returns (uint256)
    {
        return 0;
    }

    function redeemedSupply(uint256, uint256)
        public
        pure
        override
        returns (uint256)
    {
        return 0;
    }

    function activeSupply(uint256, uint256)
        public
        pure
        override
        returns (uint256)
    {
        return 0;
    }

    function burnedSupply(uint256, uint256)
        public
        pure
        override
        returns (uint256)
    {
        return 0;
    }

    function transferFrom(address, address, Transaction[] calldata)
        external override {}

    function transferAllowanceFrom(address, address, Transaction[] calldata)
        external override {}

    function issue(address, Transaction[] calldata)
        external override {}

    function redeem(address, Transaction[] calldata)
        external override {}

    function burn(address, Transaction[] calldata)
        external override {}

    function approve(address, Transaction[] calldata)
        external override {}

    function setApprovalFor(address operator, bool approved)
        external override
    {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalFor(msg.sender, operator, approved);
    }

    function classValuesFromTitle(uint256, string memory)
        external pure override returns (ValuesExtension memory)
    {
        revert();
    }

    function nonceValuesFromTitle(uint256, uint256, string memory)
        external pure override returns (ValuesExtension memory)
    {
        revert();
    }
}