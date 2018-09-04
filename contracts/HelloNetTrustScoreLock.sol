pragma solidity 0.4.24;

import "zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";


/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract TokenTimelock {
    using SafeERC20 for ERC20Basic;
    using SafeMath for uint256;

    // ERC20 basic token contract being held
    ERC20Basic public token;

    // beneficiary and token number to be send after contract tokens are released
    struct TokensLock {
        address beneficiary;
        uint256 numTokens;
    }

    //List with address and number of tokens lock
    TokensLock[] private tokensLockList;

    mapping(address => uint256) private indexReference;

    // timestamp when token release is enabled
    uint256 public releaseTime;

    constructor(
        ERC20Basic _token,
        address _beneficiary,
        uint256 _numTokens,
        uint256 _releaseTime
    )
    public {
      // solium-disable-next-line security/no-block-members
        require(_releaseTime > block.timestamp);
        token = _token;
        tokensLockList.push(TokensLock({beneficiary:_beneficiary, numTokens:_numTokens}));
        indexReference[_beneficiary] = tokensLockList.length;
        releaseTime = _releaseTime;
    }

  // ***Owneronly***
    function addTokensToLock(
        address _beneficiary,
        uint256 _numTokens
    )
    public
    {
        require(releaseTime > block.timestamp);
        uint256 totalTokens = _numTokens;
        uint256 id = indexReference[_beneficiary];
        if (id != 0) {// checks if beneficiary address exists
            id.sub(1);// tokensLockList starts with id 0
            uint256 numTokensLocked= tokensLockList[id].numTokens;
            totalTokens.add(numTokensLocked);
        }
        tokensLockList.push(TokensLock({beneficiary:_beneficiary, numTokens:totalTokens}));
        indexReference[_beneficiary] = tokensLockList.length;
    }

    //** TODO: function to return the tokens locked by address
    function getTokensLock(address _beneficiary) public view returns (uint256) {
        uint256 id = indexReference[_beneficiary] - 1;
        return tokensLockList[id].numTokens;
    }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
    function release() public {
      // solium-disable-next-line security/no-block-members
        require(block.timestamp >= releaseTime);

        uint256 amount =0;
        for (uint i = 0; i < tokensLockList.length; i++) {
            uint256 tokensLock = token.balanceOf(this);
            amount = tokensLockList[i].numTokens;
            require(tokensLock >= amount);
            require(amount > 0);
            token.safeTransfer(tokensLockList[i].beneficiary, amount);
        }
    }
}
