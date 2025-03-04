Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', controllers: {
    confirmations: 'users/confirmations',
    passwords: 'users/passwords',
    sessions: 'users/sessions',
    token_validations: 'users/token_validations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }, via: [:get, :post]
end
