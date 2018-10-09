@route=-> Router.route(&0, where:\server)

@with-obj=(res, obj)->
	res
		..setHeader \Content-Type \application/json
		..setHeader \Access-Control-Allow-Origin \*
		..end JSON.stringify obj


route \/ticker/:symbol .get (req,res,next)->
	sym = @params.symbol
	(cycle=~> HTTP.call \GET "https://api.coinmarketcap.com/v1/ticker/#{symbol-to-id sym}/?convert=ETH" (err,p)~>
		inp = JSON.parse p.content
		if inp
			price = inp[0].price_eth
			if price
				BN = new BigNumber price
				out = BN.mul('1000000000000000000').toString!
				res.end JSON.stringify priceWei: out

			else 	
				res.end JSON.stringify priceWei: null
		else cycle!
	)!



