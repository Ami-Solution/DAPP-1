Router.route \new_loan_request, path:\new-loan-request template:\newLoanRequest

template \newLoanRequest -> main_blaze do
    loading-component!
    div class:"message #{state.get \message-class }",
        p style:\font-size:20px,
            "This includes " b "#{+state.get('fee-sum')/10^18} ETH"; " deployment fees and can take 3-5 minutes"

        p style:\font-size:20px,
            'New ' 
            b 'Loan Request'
            ' will be then available in ’All Loan Requests’ window.'
            br!

        d \.center,
            div class:'row', 
                # d \.header 'Collateral Type'    
                # div class:'form-check',
                #     label class:'form-check-label',
                #         input class:'form-check-input' type:'radio' name:'contract-type' id:'gridRadios1' value:\0 checked:''
                #         "Tokens"
                # div class:'form-check',
                #     label class:'form-check-label',
                #         input class:'form-check-input' type:'radio' name:'contract-type' id:'gridRadios2' value:\1
                #         "Domain"
            div class:'row', 
                d \.header 'Currency'    
                div class:'form-check',
                    label class:'form-check-label',
                        input class:'form-check-input' type:'radio' name:'contract-currency' id:'gridRadios4' value:\0 checked:''
                        "ETH"
                div class:'form-check',
                    label class:'form-check-label',
                        input class:'form-check-input' type:'radio' name:'contract-currency' id:'gridRadios5' value:\1
                        "USD"

        button class:'new-loan-request card-button bgc-primary blue',  \Create


Template.newLoanRequest.events do

    'click .new-loan-request':->
        params = {from:web3.eth.defaultAccount, gasPrice:15000000000, value:config.BALANCE_FEE_AMOUNT_IN_WEI}
        type = 0
        currency = +$('input[name="contract-currency"]:checked').val!
        ledger.getLrCount (err, BN)->               
            num = +lilNum-toStr(BN) 
            state.set \new_contract num
            web3.eth.contract(config.LEDGERABI).at(state.get(\ETH_MAIN_ADDRESS)).newLr type, currency, params, (err,res)->
                if err => console.log \err: err
                if res 
                    console.log \thash: res
                    state.set \thash res
                    
                    state.set \transact-to-address state.get(\ETH_MAIN_ADDRESS)
                    state.set \transact-value      state.get(\fee-sum)
                    Router.go \success   


Template.newLoanRequest.created =->
    state.set \selected-class \new-loan
    state.set \message-class \hidden
    state.set \loading-class ''
        
Template.newLoanRequest.rendered =~>

    web3?eth.contract(config.LEDGER-ABI).at(state.get(\ETH_MAIN_ADDRESS)).getFeeSum (err, res)~>
        if err => return err 
        fee-sum = lilNum-toStr res
        state.set \fee-sum fee-sum
        state.set \message-class ''
        state.set \loading-class \hidden
