RPC_URL=https://eth-sepolia.api.onfinality.io/public

forge script --via-ir script/TuringGame.s.sol:TuringGameScript \
    --rpc-url $RPC_URL \
     -vvvv --broadcast