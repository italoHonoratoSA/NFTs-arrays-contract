// SPDX-License-Identifier: MIT

/**

 */

pragma solidity ^0.8.0;


//Declaração do codificador experimental ABIEncoderV2 para retornar tipos dinâmicos
pragma experimental ABIEncoderV2;


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
*/


abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (uint256);    

    function transfer(address to, uint256 amount) external returns (bool);
}


interface IUniswapV2Router {
    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}


interface IUniswapV2Pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
    function getReserves() external view returns 
    (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);


}


interface IUniswapV2Factory {
    function getPair(address token0, address token1) external returns (address);
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
}


/**
 * @dev Collection of functions related to the address type
 */
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract CFarNFT is Pausable, Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using Address for address;

    uint256 public amountTokensDepositedBUSD;

    uint256 public _decimals = 8;
    uint256 public amountPriceNFT = 500 * 10 ** _decimals;

    uint256 public timeDeployContract;
    uint256 public timeOpenPoolsStake;
    uint256 public lastBalanceOfAddressThis;
    
    //stats
    uint256 public howManyNFTsold;
    //NFT vendidas por CFarm
    uint256 public totalSoldCInFarm;
    //NFT vendidas por BUSD
    uint256 public totalSoldInBUSD;
    //NFT vendidas por BUSD, mas contadas em tokens CFarm
    uint256 public totalSoldInBUSD_convertedByCFarm;

    uint256 public howManyNFTinStake;
    uint256 public totalBalanceReceivedContract;
    uint256 public lastBalanceOfCFarmContract;

    //address public   addressCFarm =            0x8dd435d3484AF2914a15463594e8DB1fd135e1B8;
    //address internal addressBUSD =          0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    //address internal addressPCVS2  =   0x10ED43C718714eb63d5aA57B78B54704E256024E;
    //address internal addressWBNB =          0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address public   addressCFarm = 0x1a5ed33398c6B0Dfd0902B21b7161b3AfA2A58ad;
    address internal addressBUSD = 0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47;
    address internal addressPCVS2  = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address internal addressWBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    address public   treasuryWallet = 0xEBA51a59E7130cE4bf31E4D7eaC463FD89b9C0f8;
    address public   marketingWallet = 0xEBA51a59E7130cE4bf31E4D7eaC463FD89b9C0f8;

    address[] public allAddressBuyerNFT;
    uint256[] public allWichTokenPurchasedNFT;
    uint256[] public allNFTidBuyed;

    address[] public allAddressStakerNFT;
    uint256[] public allNFTidStaked;

    address[] public allAddressClaimedNFT;
    uint256[] public allNFTidClaimed;

    uint256[] public storeAmountDiferenceReceived;
    uint256[] public storeTimeDiferenceReceived;
    uint256[] public storeHowManyNFTinStake;

    mapping(address => infoBuyer) mappingInfoBuyer;
    mapping(address => infoSold) mappingInfoSold;
    mapping(address => NFTinStake) mappingStakeNFT;
    mapping(address => NFTClaimed) mappingClaimNFT;

    struct infoBuyer {
        address addressBuyer;
        uint256[] positionBuyNFT;
        uint256[] NFTid;
        uint256[] timePurchased;
        uint256[] pricePurchasedCFarm;
        uint256[] whatsToken;
        
    }

    struct infoSold {
        address addressBuyer;
        uint256[] positionSoldNFT;
        uint256[] NFTid;
        uint256[] timeSold;
        uint256[] priceSoldCFarm;
        uint256[] whatsToken;
        
    }
    struct NFTinStake {
        address addressStaker;
        uint256[] idNFTsInStake;
        uint256[] indexStake;
        uint256[] startStake;
        uint256[] lastIndexAmountDiferenceReceived;
        uint256 totalCFarmClaimed;
    }

    struct NFTClaimed {
        address addressStaker;
        uint256[] idNFTsClaimed;
        uint256[] indexClaimed;
        uint256[] timeClaimed;
        uint256 lastIndexAmountDiferenceReceived2;
        uint256 totalCFarmClaimed;
    }



    event NFTpurchased(address indexed addressBuyer, uint256 ID, uint256 indexArray, uint256 price, uint256 tempo);

    receive() external payable { }

    constructor() {
        timeDeployContract = block.timestamp;
        timeOpenPoolsStake = block.timestamp;
    }
   
    function getDaysPassed() public view returns (uint256){
        return (block.timestamp - timeDeployContract).div(1 days); 
    }

    //as 2 funções seguintes retornam os array dos compradores das NFTs
    function getAllAddressBuyerNFT() public view returns (address[] memory) {
        return allAddressBuyerNFT;
    }

    function getAllWhichTokenPurchasedNFT() public view returns (uint256[] memory) {
        return allWichTokenPurchasedNFT;
    }

    function getAllNFTidBuyed() public view returns (uint256[] memory) {
        return allNFTidBuyed;
    }

    function getAllAddressStakerNFT() public view returns (address[] memory) {
        return allAddressStakerNFT;
    }

    function getAllNFTidStaked() public view returns (uint256[] memory) {
        return allNFTidStaked;
    }

    function getAllAddressClaimedNFT() public view returns (address[] memory) {
        return allAddressClaimedNFT;
    }

    function getAllNFTidClaimed() public view returns (uint256[] memory) {
        return allNFTidClaimed;
    }

    function getInfosBuy(address buyer) public view returns (
        uint256[] memory positionBuyNFT,
        uint256[] memory NFTid,
        uint256[] memory timePurchased,
        uint256[] memory pricePurchasedCFarm,
        uint256[] memory whatsToken) {

        return (
            mappingInfoBuyer[buyer].positionBuyNFT,
            mappingInfoBuyer[buyer].NFTid,
            mappingInfoBuyer[buyer].timePurchased,
            mappingInfoBuyer[buyer].pricePurchasedCFarm,
            mappingInfoBuyer[buyer].whatsToken);
    }


    function getInfosSell(address buyer) public view returns (
        uint256[] memory positionSoldNFT,
        uint256[] memory NFTid,
        uint256[] memory timeSold,
        uint256[] memory priceSoldCFarm,
        uint256[] memory whatsToken) {
        
        return (
            mappingInfoSold[buyer].positionSoldNFT,
            mappingInfoSold[buyer].NFTid,
            mappingInfoSold[buyer].timeSold,
            mappingInfoSold[buyer].priceSoldCFarm,
            mappingInfoSold[buyer].whatsToken);
    }

    function getInfosStake(address buyer) public view returns (
        uint256[] memory idNFTsInStake,
        uint256[] memory indexStake,
        uint256[] memory startStake) {

        return (
            mappingStakeNFT[buyer].idNFTsInStake,
            mappingStakeNFT[buyer].indexStake,
            mappingStakeNFT[buyer].startStake);
    }



    //retorna a conversão para BUSD dos tokens CFarm
    function getPriceCFarmInBUSD(uint256 amount) public view returns (uint256) {
        uint256 retorno;
        if (amount != 0) {
            // generate the uniswap pair path of W6 to WBNB/BNB
            address[] memory path = new address[](3);
            path[0] = addressCFarm;
            path[1] = addressWBNB;
            path[2] = addressBUSD;

            uint256[] memory amountOutMins = IUniswapV2Router(addressPCVS2)
            .getAmountsOut(amount, path);
            retorno = amountOutMins[path.length -1];
        }
        return retorno;
    } 


    function removeArray(uint _index) public {
        //Remova o elemento da matriz deslocando os elementos da direita para a esquerda
        require(_index < mappingInfoBuyer[msg.sender].positionBuyNFT.length, "index out of bound");

        for (uint i = _index; i < mappingInfoBuyer[msg.sender].positionBuyNFT.length - 1; i++) {
            mappingInfoBuyer[msg.sender].positionBuyNFT[i] =
            mappingInfoBuyer[msg.sender].positionBuyNFT[i + 1];
        }
        mappingInfoBuyer[msg.sender].positionBuyNFT.pop();
    }

    function findIndexIDinStakeArray(address staker, uint256 ID) public view returns (uint256 i) {

        uint256 idNFT_length = mappingStakeNFT[staker].idNFTsInStake.length;
        uint256 index = 10 ** 10;
        for(i = 0; i < idNFT_length; i++) {
            if (ID == mappingStakeNFT[staker].idNFTsInStake[i]){
                index = i;
            }
        }
        return index;
    }


    function NFTwasBuyed(uint256 ID) public view returns (bool) {

        uint256 IDsold_length = allNFTidBuyed.length;
        for(uint256 i; i < IDsold_length; i++) {
            if (ID == allNFTidBuyed[i]) return true;
        }
        return false;
    }

    function NFTwasStaked(uint256 ID) public view returns (bool) {

        uint256 i; 
        uint256 IDstaked_length = allNFTidStaked.length;
        for(i; i < IDstaked_length; i++) {
            if (ID == allNFTidStaked[i]) return true;
        }
        return false;
    }

    function NFTwasClaimed(uint256 ID) public view returns (bool) {

        uint256 i; 
        uint256 IDstaked_length = allNFTidStaked.length;
        for(i; i < IDstaked_length; i++) {
            if (ID == allNFTidClaimed[i]) return true;
        }
        return false;
    }

    function updateBalance() public {

        uint256 diferenceReceivedContract = 
        IERC20(addressCFarm).balanceOf(address(this)) -  lastBalanceOfCFarmContract;

        if (diferenceReceivedContract != 0) {
            totalBalanceReceivedContract += diferenceReceivedContract;

            storeAmountDiferenceReceived.push(diferenceReceivedContract);
            storeTimeDiferenceReceived.push(block.timestamp);
            storeHowManyNFTinStake.push(howManyNFTinStake);
        }
    }

    //a base da compra é em tokens CFarm
    function buyNFT(address buyer, uint256 ID, uint256 wichToken) public {
        require(wichToken == 1 || wichToken == 2, "Forma de pagamento selecionada invalida");
        uint256 priceBUSD;

        if (NFTwasBuyed(ID) == false) {

            //BUSD
            if (wichToken == 1) {
                priceBUSD = getPriceCFarmInBUSD(amountPriceNFT);
                require(IERC20(addressBUSD).balanceOf(buyer) >= priceBUSD, "Voce nao possui BUSD suficiente");
                totalSoldInBUSD += priceBUSD;
                totalSoldInBUSD_convertedByCFarm += amountPriceNFT;
                IERC20(addressBUSD).transferFrom(buyer, marketingWallet, priceBUSD);

            //cfarm
            } else if (wichToken == 2) {
                require(IERC20(addressCFarm).balanceOf(buyer) >= amountPriceNFT, "Voce nao possui tokens suficiente");
                totalSoldCInFarm += amountPriceNFT;
                IERC20(addressCFarm).transferFrom(buyer, marketingWallet, amountPriceNFT);

            }

            //updateBalance();

            howManyNFTsold++;

            uint256 indexArray = mappingInfoBuyer[buyer].positionBuyNFT.length;
            mappingInfoBuyer[buyer].addressBuyer = buyer;
            mappingInfoBuyer[buyer].positionBuyNFT.push(indexArray);
            mappingInfoBuyer[buyer].NFTid.push(ID);
            mappingInfoBuyer[buyer].timePurchased.push(block.timestamp);
            mappingInfoBuyer[buyer].pricePurchasedCFarm.push(amountPriceNFT);
            mappingInfoBuyer[buyer].whatsToken.push(wichToken);

            allAddressBuyerNFT.push(buyer);
            allWichTokenPurchasedNFT.push(wichToken);
            allNFTidBuyed.push(ID);

            emit NFTpurchased (buyer, ID, indexArray, amountPriceNFT, 1);
        }
    }


    function buyManyNFTs (address buyer, uint256[] memory ID, uint256 wichToken) public whenNotPaused {
        require(buyer == _msgSender() || _msgSender() == owner(), "Somente a conta detentora que pode comprar");
        require(mappingInfoBuyer[buyer].NFTid.length != 0, "Voce nao tem NFT compradas");
        require(timeOpenPoolsStake != 0, "As pools de stake ainda nao estao abertas");
        
        //verifica se cada ID está livre para compra
        //chama buyNFT para cada ID
        uint256 ID_length = ID.length;
        uint256 count;
        for(; count < ID_length; count++) {
            require(NFTwasBuyed(ID[count]) == false, "Pelo menos uma das NFTs ja foi vendida");
            buyNFT(buyer,ID[count],wichToken);
        }

    }

    function stakeNFT(address staker, uint256 ID) public whenNotPaused {
        require(staker == _msgSender() || _msgSender() == owner(), "Somente a conta detentora que pode apostar");
        require(mappingInfoBuyer[staker].NFTid.length != 0, "Voce nao tem NFT compradas");
        require(timeOpenPoolsStake != 0, "As pools de stake ainda nao estao abertas");
        
        if (NFTwasBuyed(ID) == true && NFTwasStaked(ID) == false) {

            uint256 indexArray = mappingStakeNFT[staker].indexStake.length;
            
            mappingStakeNFT[staker].addressStaker = staker;
            mappingStakeNFT[staker].indexStake.push(indexArray);
            mappingStakeNFT[staker].idNFTsInStake.push(ID);
            mappingStakeNFT[staker].startStake.push(block.timestamp);

            allAddressStakerNFT.push(staker);
            allNFTidStaked.push(ID);

            howManyNFTinStake ++;
            updateBalance();
        }
    }

    function stakeManyNFTs(address staker, uint256[] memory ID) public whenNotPaused {
        require(staker == _msgSender() || _msgSender() == owner(), "Somente a conta detentora que pode apostar");
        require(mappingInfoBuyer[staker].NFTid.length != 0, "Voce nao tem NFT compradas");
        require(timeOpenPoolsStake != 0, "As pools de stake ainda nao estao abertas");
        
        uint256 ID_length = ID.length;
        uint256 count;
        for (count;count < ID_length; count++) {
            require(NFTwasStaked(ID[count]) == false, "Pelo menos uma das NFTs ja foi apostada em stake");
            stakeNFT(staker, ID[count]);
        }

    }


    function claimRewardsAllRewards(address staker) public {
        require(staker == _msgSender() || _msgSender() == owner(), "Somente a conta detentora que pode apostar");
        require(mappingInfoBuyer[staker].NFTid.length != 0, "Voce nao tem NFT compradas");
        require(timeOpenPoolsStake != 0, "As pools de stake ainda nao estao abertas");

        uint256 rewards;
        updateBalance();

        uint256 lastIndexArray = mappingStakeNFT[staker].indexStake.length;
        uint256 lengthStoreAmountDiference = storeAmountDiferenceReceived.length;
        uint256 count;

        for (count; count < lastIndexArray ; count++) {
            uint256 ID = mappingStakeNFT[staker].idNFTsInStake[count];
            uint256 getIndex = findIndexIDinStakeArray(staker,ID);
            // uint256 timePurchasedTemp = mappingStakeNFT[staker].startStake[getIndex];
            uint256 lastIndex = mappingStakeNFT[staker].lastIndexAmountDiferenceReceived[getIndex];

            if (NFTwasBuyed(ID) == true && NFTwasStaked(ID) == true) {
                
                uint256 rewardsTemp;

                if (//timePurchasedTemp < storeTimeDiferenceReceivedTemp && 
                lastIndex < lengthStoreAmountDiference) {

                    for (lastIndex;lastIndex < lengthStoreAmountDiference; lastIndex++) {
                        //uint256 storeTimeDiferenceReceivedTemp = storeTimeDiferenceReceived[i];

                        rewardsTemp = storeAmountDiferenceReceived[lastIndex].div(storeHowManyNFTinStake[lastIndex]);
                        rewards += rewardsTemp;
                    }

                }
                mappingStakeNFT[staker].lastIndexAmountDiferenceReceived[getIndex] = lengthStoreAmountDiference;

            }
            if (rewards >= IERC20(addressCFarm).balanceOf(address(this))) {
                rewards = IERC20(addressCFarm).balanceOf(address(this));
            }

            IERC20(addressCFarm).transfer(staker, rewards);

            lastBalanceOfCFarmContract = IERC20(addressCFarm).balanceOf(address(this));
        }
    }

    function claimAllNFTs(address staker) public {
        require(staker == _msgSender() || _msgSender() == owner(), "Somente a conta detentora que pode apostar");
        require(mappingInfoBuyer[staker].NFTid.length != 0, "Voce nao tem NFT compradas");
        require(timeOpenPoolsStake != 0, "As pools de stake ainda nao estao abertas");

        uint256 rewards;

        uint256 lastIndexArray = mappingStakeNFT[staker].indexStake.length;
        uint256 count;
        for (count; count < lastIndexArray ; count++) {
            uint256 ID = mappingStakeNFT[staker].idNFTsInStake[count];

            if (NFTwasBuyed(ID) == true && NFTwasClaimed(ID) == false) {

                uint256 getIndex = findIndexIDinStakeArray(staker,ID);
                uint256 timePurchasedTemp = mappingStakeNFT[staker].startStake[getIndex];
                uint256 lastIndex = mappingStakeNFT[staker].lastIndexAmountDiferenceReceived[getIndex];

                updateBalance();
                
                uint256 lengthStoreAmountDiference = storeAmountDiferenceReceived.length;
                uint256 i;
                for (i;i < lengthStoreAmountDiference;i++) {
                    uint256 storeTimeDiferenceReceivedTemp = storeTimeDiferenceReceived[i];

                    uint256 rewardsTemp;

                    if (timePurchasedTemp < storeTimeDiferenceReceivedTemp 
                    && lastIndex < lengthStoreAmountDiference) {
                        rewardsTemp = storeAmountDiferenceReceived[i].div(storeHowManyNFTinStake[i]);
                        rewards += rewardsTemp;
                    }

                }
                mappingStakeNFT[staker].lastIndexAmountDiferenceReceived[getIndex] = lengthStoreAmountDiference - 1;
            }

            allAddressClaimedNFT.push(staker);
            allNFTidClaimed.push(ID);

            mappingClaimNFT[staker].addressStaker = staker;
            mappingClaimNFT[staker].idNFTsClaimed.push(ID);
            mappingClaimNFT[staker].indexClaimed.push(count);
            mappingClaimNFT[staker].timeClaimed.push(block.timestamp);
            mappingClaimNFT[staker].idNFTsClaimed.push(ID);


            IERC20(addressCFarm).transfer(staker, rewards);

            lastBalanceOfCFarmContract = IERC20(addressCFarm).balanceOf(address(this));
        }
    }


/*
    //a base da compra é em tokens CFarm
    function sellNFT(address buyer, uint256 ID, uint256 wichToken) public {
        require(wichToken == 1 || wichToken == 2, "Forma de pagamento selecionada invalida");
        uint256 priceBUSD;

        if (NFTwasBuyed(ID) == true && NFTwasClaimed(ID) == true) {

            //BUSD
            if (wichToken == 1) {
                priceBUSD = getPriceCFarmInBUSD(amountPriceNFT);
                require(IERC20(addressBUSD).balanceOf(buyer) >= priceBUSD, "Voce nao possui BUSD suficiente");
                totalSoldInBUSD += priceBUSD;
                totalSoldInBUSD_convertedByCFarm += amountPriceNFT;
                IERC20(addressBUSD).transferFrom(buyer, marketingWallet, priceBUSD);

            //cfarm
            } else if (wichToken == 2) {
                require(IERC20(addressCFarm).balanceOf(buyer) >= amountPriceNFT, "Voce nao possui tokens suficiente");
                totalSoldCInFarm += amountPriceNFT;
                IERC20(addressCFarm).transferFrom(buyer, marketingWallet, amountPriceNFT);

            }

            //updateBalance();

            howManyNFTsold++;

            uint256 indexArray = mappingInfoBuyer[buyer].positionBuyNFT.length;
            mappingInfoBuyer[buyer].addressBuyer = buyer;
            mappingInfoBuyer[buyer].positionBuyNFT.push(indexArray);
            mappingInfoBuyer[buyer].NFTid.push(ID);
            mappingInfoBuyer[buyer].timePurchased.push(block.timestamp);
            mappingInfoBuyer[buyer].pricePurchasedCFarm.push(amountPriceNFT);
            mappingInfoBuyer[buyer].whatsToken.push(wichToken);

            allAddressBuyerNFT.push(buyer);
            allWichTokenPurchasedNFT.push(wichToken);
            allNFTidBuyed.push(ID);

            emit NFTpurchased (buyer, ID, indexArray, amountPriceNFT, 1);
        }
    }

*/

    function setamountPriceNFT(uint256 _amountPriceNFT) public {
        amountPriceNFT = _amountPriceNFT;
    }

    
    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function managerBNB () external onlyOwner {
        uint256 amount = address(this).balance;
        payable(msg.sender).transfer(amount);
    }

    function managerERC20 (address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }


    function setOpenPoolsStake () external onlyOwner {
        timeOpenPoolsStake = block.timestamp;
    }

    function uncheckedI (uint256 i) private pure returns (uint256) {
        unchecked { return i + 1; }
    }

/*
    function finalizePoolStake(address[] memory stakers, uint256[] memory whatsNumberStake) 
    external onlyOwner {

        if (whichPool == 1) {
            for(uint256 i = 0; i < stakers.length; i = uncheckedI(i)) {  
            }

        } else {
            for(uint256 i = 0; i < stakers.length; i = uncheckedI(i)) {  
            }
        }

    }

*/
}
