@lr = call:(method)~>(address)~>(...args)-> 
	# if !address?length || address?length < 30 => address = big-zero
	web3?eth.contract(config.LR-ABI).at(address)[method](...args)
	
@ledger = call:(method)~>(...args)~> web3?eth.contract(config.LEDGER-ABI).at(state.get(\ETH_MAIN_ADDRESS))[method](...args)

@ticker = call:(method)~>(...args)~> web3?eth.contract(config.TICKER-ABI).at(state.get(\ETH_TICKER_ADDRESS))[method](...args)
@init   = (obj)~> (method)~> obj[method] = obj[\call](method)

map init(ledger), ["mainAddress", "registrarAddress", "repTokenAddress", "getLr", "getLrFunded", "ethTickerAddress", "newLrAndSetData", "ensRegistryAddress", "unlockRepTokens", "totalLrCount", "lockRepTokens", "addRepTokens", "newLr", "getLrCount", "whereToSendFee", "borrowerFeeAmount", "getLrFundedCount", "getRepTokenAddress", "approveRepTokens", "burnRepTokens", "getFeeSum"]
map init(lr), ["currentType", "wasEthWhenCreated", "creator", "changeMainAddress", "isEns", "mainAddress", "registrarAddress", "lenderFeeAmount", "changeLedgerAddress", "isCanDefault", "token_smartcontract_address", "getBorrower", "getTokenSmartcontractAddress", "ethTickerAddress", "token_infolink", "getCurrentState", "waitingForPayback", "getNextInstallmentDaysLeft", "premium_wei", "getNeededSumByBorrower", "installments_period_days", "installment_paid", "token_amount", "waitingForLender", "installments_count", "getTokenAmount", "ensRegistryAddress", "isRep", "wanted_wei", "borrower", "getTokenInfoLink", "getTokenName", "setData", "token_name", "getLender", "ens_domain_hash", "cancell", "whereToSendFee", "getInstallmentsPassed", "getNeededSumByLender", "lender", "getInstallmentPenalty", "start", "getEnsDomainHash", "requestDefault", "currency", "returnTokens", "convertToEth"]
map init(ticker), ["lastTimeRateUpdated", "isNeedToUpdateEthToUsdRate", "oraclizeFee", "ethPriceInUsd", "getNow", "getEthToUsdRate", "updateEthToUsdRate", "ethPriceInUsdInt", "newOraclizeQuery", "priceReceived"]

@lr-keys=-> 
	if web3?eth.contract(config.LRABI).abi
		compact map((.name), web3?eth.contract(config.LRABI).abi)

@ledger-keys=-> 
	if web3?eth.contract(config.LEDGERABI).abi
		compact map((.name), web3?eth.contract(config.LEDGERABI).abi)

@ticker-keys=->
	if web3?eth.contract(config.TICKERABI).abi
		compact map((.name), web3?eth.contract(config.TICKERABI).abi)


@get-all-lr-data =(address)->(cb)->
	out = {}
	lr.currency(address) ->  				out.currency = +lilNum-toStr &1    
	lr.wanted_wei(address) ->  				out.WantedWei = &1    
	lr.premium_wei(address) -> 				out.PremiumWei = &1
	lr.getTokenName(address) ->                  out.TokenName = &1
	lr.getTokenInfoLink(address) -> 			out.TokenInfoLink = &1
	lr.getTokenSmartcontractAddress(address) ->  out.TokenSmartcontractAddress = &1
	lr.getBorrower(address) -> 			     out.Borrower = &1
	
	lr.installments_count(address) ->            out.installments_count  = +lilNum-toStr &1
	lr.installments_period_days(address) ->      out.installments_period_days = +lilNum-toStr &1
	lr.installment_paid(address) ->              out.installments_paid = +lilNum-toStr &1
	lr.getNextInstallmentDaysLeft(address) ->    out.days_left = +lilNum-toStr &1

	lr.isCanDefault(address) ->                  out.isCanDefault =  &1

	lr.getCurrentState(address) -> 			out.State = +lilNum-toStr &1
	lr.getLender(address) -> 				out.Lender = &1
	lr.getTokenAmount(address) -> 			out.TokenAmount =  +lilNum-toStr &1
	lr.isEns(address) ->					out.isEns = &1
	lr.isRep(address) ->					out.isRep = &1
	lr.getEnsDomainHash(address) ->			out.EnsDomainHash = &1


	lr.getNeededSumByBorrower(address) ->		out.neededSumByBorrower = &1
	lr.getNeededSumByLender(address) ->	   	out.neededSumByLender = &1

	ledger.getFeeSum ->						out.feeSum = &1

	ticker.ethPriceInUsd ->				     out.rate = (+&1).to-fixed 2
	lr.wasEthWhenCreated(address) ->			out.was = (0.01/(+bigNum-toStr &1)).to-fixed 2



	cycle =-> 
		new-cycle = false
		for key in <[ currency WantedWei PremiumWei TokenName TokenInfoLink TokenSmartcontractAddress Borrower installments_count installments_period_days installments_paid State Lender TokenAmount isEns isRep EnsDomainHash days_left isCanDefault neededSumByBorrower neededSumByLender feeSum rate was ]>
			if typeof out[key] == \undefined => new-cycle := true
		
			# console.log \out: out
		if new-cycle => Meteor.setTimeout (->cycle!), 50
		
		else 
			console.log \TokenSmartcontractAddress: out.TokenSmartcontractAddress
			console.log \contract-data-ready: out



			cb null, out

	cycle!

@get-rep-balance =(address,cb)-> cb null, 0


