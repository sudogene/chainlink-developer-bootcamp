pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract PriceExercise is ChainlinkClient {
    
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    bool public priceFeedGreater;
    int256 public price;

    AggregatorV3Interface internal priceFeed;


    constructor(address _oracle, string memory _jobId, uint256 _fee, address _link,
        address AggregatorAddress) public {

        if (_link == address(0)) {
            setPublicChainlinkToken();
        } else {
            setChainlinkToken(_link);
        }
        oracle = _oracle;
        jobId = stringToBytes32(_jobId);
        fee = _fee;
        priceFeed = AggregatorV3Interface(AggregatorAddress);

    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }

    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 10**8 (to remove decimal places from data).
     * This is specifically for BTCUSD
     */
    function requestPriceData() public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        // Set the URL to perform the GET request on
        request.add("get", "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC&tsyms=USD");

        // Set the path to obtain BTCUSD price
        request.add("path", "RAW.BTC.USD.PRICE");

        // Multiply the result by 10**8 to remove decimals
        int timesAmount = 10**8;
        request.addInt("times", timesAmount);

        // Send the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    /**
     * Receive the response in the form of int256
     */ 
    function fulfill(bytes32 _requestId, int256 _price) public recordChainlinkFulfillment(_requestId) {
        price = _price;
        priceFeedGreater = getLatestPrice() > price;
    }

    /**
     * Withdraw LINK from this contract
     *
     * NOTE: DO NOT USE THIS IN PRODUCTION AS IT CAN BE CALLED BY ANY ADDRESS.
     * THIS IS PURELY FOR EXAMPLE PURPOSES ONLY.
     */
    function withdrawLink() external {
        LinkTokenInterface linkToken = LinkTokenInterface(chainlinkTokenAddress());
        require(linkToken.transfer(msg.sender, linkToken.balanceOf(address(this))), "Unable to transfer");
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
}