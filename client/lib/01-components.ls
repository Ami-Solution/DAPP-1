template \noMetamask -> main_blaze noMetamask!
Router.route \noMetamask, path: \/noMetamask

@noMetamask=-> div style:'padding:100px' class:\container ,
		h1 style:'font-size:50px; display:block', 'No Metamask'
		p style:'font-size:20px; padding-top:15px;padding-bottom:15px', 'This site requires the Metamask plugin for Google Chrome.'
		a class:'btn btn-primary btn-lg' href:'https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn', 'Download Metamask'

template \wrong_network -> main_blaze wrong_network!
Router.route \wrong_network, path: \/wrong_network

@wrong_network=-> div style:'padding:100px' class:\container ,
		h1 style:'font-size:50px; display:block', 'Wrong network'
		p style:'font-size:20px; padding-top:15px;padding-bottom:15px', 'You are connected to the wrong network. Please switch to main/rinkeby network to make loans.'
		# a class:'btn btn-primary btn-lg' href:'https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn', 'Download Metamask'

@error-component =-> 
	h1 class:"#{state.get \error-class }", 'Wrong address'

@loading-component =-> 
	div class:"loading #{state.get \loading-class } container" style:'padding:100px',  
		h1 style:'font-size:50px; display:block', 'Loading'
		p style:'font-size:20px; padding-top:15px;padding-bottom:15px', 'Please, wait...'

template \loading -> main_blaze do
	div style:'padding:100px' class:\container ,
		h1 style:'font-size:50px; display:block', 'Loading'
		p style:'font-size:20px; padding-top:15px;padding-bottom:15px', 'Please, wait...'

@not-found-component =-> 
	div class:"#{state.get(\not-found-class)} container" style:'padding:100px',  
		h1 style:'font-size:50px; display:block', &0
		p style:'font-size:20px; padding-top:15px;padding-bottom:15px', &1

template \notFound -> 
	div class:"#{state.get(\not-found-class)} container" style:'padding:100px',  
		h1 style:'font-size:50px; display:block', 'Error 404'
		p style:'font-size:20px; padding-top:15px;padding-bottom:15px', 'Not found'

template \reload -> main_blaze do
	div style:'padding:100px' class:\container ,
		h1 style:'font-size:50px; display:block', 'Can not get account address'
		p style:'font-size:20px; padding-top:15px;padding-bottom:15px', 'Please, enter password in the Metamask, or reload page.'
		button class:'btn btn-danger btn-lg' onclick:'location.reload()', 'Reload page'

T \success -> main_blaze do
	div style:'padding:100px' class:\container ,
		h1 style:'font-size:50px; display:block', 'Loading...'
		p style:'font-size:20px; padding-top:15px;padding-bottom:15px', 
			'Please wait. Action will be completed in the next few minutes'
			br!
			if state.get(\thash) => "Transaction hash: #{state.get(\thash)}"
			br!		
			d \.hidden, global.again = false
			cycle!

		button class:'btn btn-primary btn-lg' onclick:'window.history.back()', 'Go back'


cycle=->
	if (state.get \update_usd)
		ticker.isNeedToUpdateEthToUsdRate (err,ans)->
			console.log \isNeedToUpdateEthToUsdRate ans
			if ans == false
				if global.again == false
					global.again := true
					alert 'Rate updated'
					window.history.back! 
			else
				Meteor.setTimeout (-> cycle!), 1000

	else web3.eth.getTransactionReceipt state.get(\thash), (err, obj)~>
		console.log \getTransactionReceipt: obj

		if (state.get \new_contract) 
			if obj	
				ledger.getLr ((state.get \new_contract)), (err, addr)->
					console.log \num: state.get(\new_contract), \addr: addr
					if (addr != big-zero) && (addr != \0x)
						Router.go "/loan-request/#addr"
					else Meteor.setTimeout (-> cycle!), 1000

			else Meteor.setTimeout (-> cycle!), 1000

		else
			if obj
				alert 'Transaction mined'
				window.history.back!
			else Meteor.setTimeout (-> cycle!), 1000




contract-details=(cb)-> web3.eth.getTransaction state.get(\thash), (err,res)-> cb(res)



