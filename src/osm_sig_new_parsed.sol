


pragma solidity >=0.5.10;

import "ds-value/value.sol";

contract LibNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  usr,
        bytes32  indexed  arg1,
        bytes32  indexed  arg2,
        bytes             data
    ) anonymous;

    modifier note {
        _;
        assembly {
                )
        }
    }
}

contract OSM is LibNote {

    mapping (address => uint) public wards;
    function rely(address usr) external note auth { wards[usr] = 1; }
    function deny(address usr) external note auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "OSM/not-authorized");
        _;
    }

    uint256 public stopped;
    modifier stoppable { require(stopped == 0, "OSM/is-stopped"); _; }

    function add(uint64 x, uint64 y) internal pure returns (uint64 z) {
        z = x + y;
        require(z >= x);
    }

    address public src;
    uint16  constant ONE_HOUR = uint16(1);
    uint16  constant ONE_HOUR_FOR_EMITSIG_DELAY= 1;
    uint16  public hop = ONE_HOUR;
    uint64  public zzz;

    struct Feed {
        uint128 val;
        uint128 has;
    }

    Feed cur;
    Feed nxt;

    mapping (address => uint256) public bud;

    modifier toll { require(bud[msg.sender] == 1, "OSM/contract-not-whitelisted"); _; }

    event LogValue(bytes32 val);

    function stop() external note auth {
        stopped = 1;
    }
    function start() external note auth {
        stopped = 0;
    }

    function change(address src_) external note auth {
        src = src_;
    }

    function era() internal view returns (uint) {
        return block.timestamp;
    }

    function prev(uint ts) internal view returns (uint64) {
        require(hop != 0, "OSM/hop-is-zero");
        return uint64(ts - (ts % hop));
    }

    function step(uint16 ts) external auth {
        require(ts > 0, "OSM/ts-is-zero");
        hop = ts;
    }

    function void() external note auth {
        cur = nxt = Feed(0, 0);
        stopped = 1;
    }

    function pass() public view returns (bool ok) {
        return era() >= add(zzz, hop);
    }
    
// Original code: signal PriceFeedUpdate(bytes32);
bytes32 private PriceFeedUpdate_key;
function set_PriceFeedUpdate_key() private {
    PriceFeedUpdate_key = keccak256("PriceFeedUpdate(bytes32)");
}
////////////////////
// Original code: handler SendUpdate;
bytes32 private SendUpdate_key;
function set_SendUpdate_key() private {
    SendUpdate_key = keccak256("SendUpdate(bytes32)");
}
////////////////////
    function Update(bytes32 unused) public {
        (bytes32 wut, bool ok) = DSValue(src).peek();
        if (ok) {
            cur = nxt;
            nxt = Feed(uint128(uint(wut)), 1);
            emit LogValue(bytes32(uint(cur.val)));
            bytes32 price = bytes32(uint(cur.val));
            emitsig PriceFeedUpdate(price).delay(ONE_HOUR_FOR_EMITSIG_DELAY);
        }
    }

    function peek() external view toll returns (bytes32,bool) {
        return (bytes32(uint(cur.val)), cur.has == 1);
    }

    function peep() external view toll returns (bytes32,bool) {
        return (bytes32(uint(nxt.val)), nxt.has == 1);
    }

    function read() external view toll returns (bytes32) {
        require(cur.has == 1, "OSM/no-current-value");
        return (bytes32(uint(cur.val)));
    }



    function kiss(address a) external note auth {
        require(a != address(0), "OSM/no-contract-0");
        bud[a] = 1;
    }

    function diss(address a) external note auth {
        bud[a] = 0;
    }

    function kiss(address[] calldata a) external note auth {
        for(uint i = 0; i < a.length; i++) {
            require(a[i] != address(0), "OSM/no-contract-0");
            bud[a[i]] = 1;
        }
    }

    function diss(address[] calldata a) external note auth {
        for(uint i = 0; i < a.length; i++) {
            bud[a[i]] = 0;
        }
    }

    function startPriceUpdate() public{
        emitsig PriceFeedUpdate(0).delay(0);
    }

    function getCurrentPrice() public returns (bytes32){
        return bytes32(uint(cur.val));
    }

    constructor(address src_) public {
        wards[msg.sender] = 1;
        src = src_;
// Original code: PriceFeedUpdate.create_signal();
set_PriceFeedUpdate_key();
assembly {
    mstore(0x00, createsignal(sload(PriceFeedUpdate_key.slot)))
}
////////////////////
// Original code: SendUpdate.create_handler("Update(bytes32)",1000000,120);
set_SendUpdate_key();
bytes32 SendUpdate_method_hash = keccak256("Update(bytes32)");
uint SendUpdate_gas_limit = 1000000;
uint SendUpdate_gas_ratio = 120;
assembly {
    mstore(
        0x00, 
        createhandler(
            sload(SendUpdate_key.slot), 
            SendUpdate_method_hash, 
            SendUpdate_gas_limit, 
            SendUpdate_gas_ratio
        )
    )
}
////////////////////
        address this_address = address(this);
// Original code: SendUpdate.bind(this_address,"PriceFeedUpdate(bytes32)");
bytes32 SendUpdate_signal_prototype_hash = keccak256("PriceFeedUpdate(bytes32)");
assembly {
    mstore(
        0x00,
        sigbind(
            sload(SendUpdate_key.slot),
            this_address,
            SendUpdate_signal_prototype_hash
        )
    )
}
////////////////////
    }

}

