// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/**
 * @title Raffle
 * @author [Foundry](https://github.com/foundry-rs)
 * @notice this contract is for creating a sample raffle
 * @dev Implements Chainlink VRF2
 */
contract Raffle is VRFConsumerBaseV2 {
    error Raffle__NotEnoughETHSent();
    error Raffle__WinnerPickTooEarly();
    error Raffle__TransferFailed();
    error Raffle_RaffleNotOpen();
    error Raffle__UpkeepNotNeeded(
        uint256 currentBalance,
        uint256 numPlayers,
        uint256 raffleState

    );

    //** Type Declarations*/
    enum RaffleState {
        OPEN, //0
        CALCULATING //1
    }
    /**
     * Constants
     */

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUMWORDS = 1;
    /**
     * Immutables
     */
    uint32 private immutable i_callbackGasLimit;
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    /**
     * State Variables
     */
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    address private s_recentWinner;
    RaffleState private s_raffleState;
    /**
     * Events
     */

    event EnteredRaffle(address indexed player);
    event PickedWinner(address indexed winner);

    constructor(
        uint256 _entranceFee,
        uint256 interval,
        uint256 lastTimeStamp,
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callBackGasLimit,
        RaffleState raffleState
    ) VRFConsumerBaseV2(vrfCoordinator) {
        i_entranceFee = _entranceFee;
        i_interval = interval;
        s_lastTimeStamp = lastTimeStamp;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callBackGasLimit;
        s_raffleState = raffleState;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughETHSent();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle_RaffleNotOpen();
        }
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }

    function performUpkeep(bytes calldata ) external {
        (bool upkeepNeeded ,) = checkUpKeep("");
        if (!upkeepNeeded){
            revert Raffle__UpkeepNotNeeded(address(this).balance, s_players.length, uint256(s_raffleState));
        }

        if ((block.timestamp - s_lastTimeStamp) <= i_interval) {
            revert Raffle__WinnerPickTooEarly();
        }
        s_raffleState = RaffleState.CALCULATING;
        // Will revert if subscription is not set and funded.
        i_vrfCoordinator.requestRandomWords(
            i_gasLane, //gaslane
            i_subscriptionId, //subscriptionId
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit, //gaslimit
            NUMWORDS //number of random numbers
        );
    }
    /**
     * @dev This is the function that the ChainLink Automation nodes call
     * to see if it's time to perform an upkeep
     * 1. The time interval has passed between raffle runs
     * 2. The raffle is in the OPEN state
     * 3. The Contract has ETH (aka, players)
     * 4. The subscription is funded with LINK (implicit)
     */

    function checkUpKeep(bytes memory) public view returns (bool upKeepNeeded, bytes memory) {
        bool timeHasPassed = ((block.timestamp - s_lastTimeStamp) >= i_interval);
        bool isOpen = (s_raffleState == RaffleState.OPEN);
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upKeepNeeded = (timeHasPassed && isOpen && hasBalance && hasPlayers);
        return (upKeepNeeded, "0x0");
    }

    function fulfillRandomWords(/**requestId*/uint256 , uint256[] memory randomWords) internal override {
        // s_players = 10
        //rng = 12
        //12 % 10 = 2
        uint256 indexOfwinner = randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfwinner];
        s_recentWinner = winner;
        s_raffleState = RaffleState.OPEN;
        (bool success,) = s_recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
        emit PickedWinner(winner);
    }

    function exitRaffle() public {}

    /**
     * Getter Function
     */
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }
}
