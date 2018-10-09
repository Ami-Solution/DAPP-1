template \layout -> 
    html lang:\en,
        head do
            meta charset:\UTF-8
            title {}, "EthLend"
        body do
            header_blaze do
                a class:\logo href:\/main/1,
                    img class:\logo-image src:\/img/logo.png alt:'EthLend logo'
                nav class:\navigation,
                    D "nav-link-wrapper",
                        a class:"nav-link js-gitter-toggle-chat-button", "Chat"
                    D "nav-link-wrapper",
                        a class:"nav-link" href:"https://github.com/ETHLend/DAPP/wiki", "Help"
                    D "nav-link-wrapper #{if state.get(\selected-class)==\main => \selected  }",
                        a class:\nav-link href:\/main/1, "All Loan Requests"
                    # D "nav-link-wrapper #{if state.get(\selected-class)==\funded => \selected  }",
                    #     a class:\nav-link href:\/funded/1, "Funded Loan Requests"
                    D "nav-link-wrapper #{if state.get(\selected-class)==\new-loan => \selected  }",
                        span class:"glyphicon glyphicon-plus-sign" aria-hidden:"true" style:'color:white; position:relative; left:15px; top:2px;'
                        a class:'nav-link with-icon' href:\/new-loan-request, "New Loan Request"
                    D "nav-link-wrapper #{if state.get(\selected-class)==\info => \selected } #{if state.get(\selected-class)==\loan => \pseudo-selected }",
                        a class:\nav-link href:\/info, "Info"
#       CHECK FOR WEB3 do
            div class:'main-shell', 
            if !web3? 
              SI @lookupTemplate \noMetamask

            else
              if state.get \ETH_MAIN_ADDRESS
                if state.get(\ETH_MAIN_ADDRESS) == \err
                  SI @lookupTemplate \wrong_network

                else SI @lookupTemplate \yield


        footer do
            div class:\footer-nav,
                a class:\footer-link href:\/main/1, "Home"
                a class:\footer-link href:'http://about.ethlend.io', "About EthLеnd"
                a class:\footer-link href:'/faq', "FAQs"
            p class:\footer-inscription, "EthLend ©2017"


Template.layout.events do
    'click .nav-link-wrapper':->
        $(\.selected).remove-class(\selected)
        $(event.target).add-class(\selected)

    # 'mouseover .nav-link-wrapper':->
    #     $(\.selected).remove-class(\selected)
    #     $(event.target).add-class(\selected)




Template.layout.rendered=->
    console.log web3.eth.defaultAccount

    ((i, s, o, g, r, a, m) ->
      i.'GoogleAnalyticsObject' = r
      i[r] = i[r] || ->
        (i[r].q = i[r].q || []).push arguments
        return
      i[r].l = 1 * new Date
      a = s.createElement o
      m = (s.getElementsByTagName o).0
      a.async = 1
      a.src = g
      m.parentNode.insertBefore a, m
      return ) window, document, 'script', 'https://www.google-analytics.com/analytics.js', 'ga'

    ga 'create', 'UA-102004013-2', 'auto'

    ga 'send', 'pageview'

    script = document.createElement 'script'
    script.setAttribute 'type', 'text/javascript'
    script.setAttribute 'src', 'https://sidecar.gitter.im/dist/sidecar.v1.js'
    script.setAttribute 'defer', 'defer'
    script.setAttribute 'async', 'async'
    (document.getElementsByTagName 'head').0.appendChild script
    ((window.gitter = {}).chat = {}).options = {
        room: 'ethlend/lobby',
        activationElement: false
    }

    state.set \addr (Router.current!originalUrl |> split \/)

    state.set \addr-last (state.get(\addr) |> last )
    state.set \addr-prelast (state.get(\addr) |> initial |> last )

    state.set \main-class     if (state.get(\addr-prelast)==\main)          => \selected else ''
    state.set \info-class     if (state.get(\addr-last)==\info)             => \selected else ''
    state.set \new-loan-class if (state.get(\addr-last)==\new-loan-request) => \selected else ''


checkAccountBalance = ->
  web3.eth.getAccounts ((err, accounts) ->
    if err isnt null
      console.log 'An error occurred: ', err
    else
      if accounts.length is 0
        swal {
          title: 'Log in to Metamask'
          text: 'You are not logged in to MetaMask. Log in to use the full functinality of the application.'
          icon: 'info'
        }
      else
        web3.eth.getBalance accounts.0, (error, result) ->
          if error
            return
          else
            if result.c.0 is 0
              swal {
                title: 'Account balance'
                text: 'Your account balance is ' + result
                icon: 'info'
              }
          return
    return )
  return

Template.layout.created=->

Template.layout.rendered=->
    #Notify if MetaMask is not installed
    if !web3? =>
        Router.go \/noMetamask
    script = document.createElement 'script'
    script.setAttribute 'type', 'text/javascript'
    script.setAttribute 'src', 'https://sidecar.gitter.im/dist/sidecar.v1.js'
    script.setAttribute 'defer', 'defer'
    script.setAttribute 'async', 'async'
    (document.getElementsByTagName 'head').0.appendChild script
    ((window.gitter = {}).chat = {}).options = {
        room: 'ethlend/lobby',
        activationElement: false
    }
