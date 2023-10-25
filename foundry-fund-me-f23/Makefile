-include .env

build:; forge build
deploy-local:
	forge script script/DeployFundMe.s.sol:DeployFundMe --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
