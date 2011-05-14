Rails.application.config.middleware.use OmniAuth::Builder do
    provider :twitter, 'ZVB3tow7zaLG7hwgQFbA', '1fV18W3wck2qjalbOpXEX0VkFRSHtSQLuwUgYTBzSdQ'
    provider :facebook, '783c846fcefe891b29c066a586f5f7b9', '7c8bd63aa744e0c71bfa1bc3b8984a3e'
end