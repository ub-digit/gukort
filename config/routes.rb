Rails.application.routes.draw do
  put 'v1.0/patrons/:id', to: 'patrons#new'
  put 'v1.0/patrons/:id/pnr', to: 'patrons#pnr'
  put 'v1.0/patrons/:id/card', to: 'patrons#card'
  get 'v1.0/nono', to: 'nonos#show'
end
