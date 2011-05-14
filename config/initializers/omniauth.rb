Rails.application.config.middleware.use OmniAuth::Builder do
    provider :twitter, 'ZVB3tow7zaLG7hwgQFbA', '1fV18W3wck2qjalbOpXEX0VkFRSHtSQLuwUgYTBzSdQ'
    if Rails.env.production?
      provider :facebook, '783c846fcefe891b29c066a586f5f7b9', '7c8bd63aa744e0c71bfa1bc3b8984a3e', {:client_options => {:ssl => {:ca_path => "/etc/ssl/certs"}}}
    else
      provider :facebook, 'e7b24e2d582302b197f8c581caf77ff9', 'eb8edeffeb13a72df62513b50be16441', {:client_options => {:ssl => {:ca_path => "/etc/ssl/certs"}}}
    end
end