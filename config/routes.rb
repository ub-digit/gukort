Rails.application.routes.draw do
  get 'library_card_number/generate'

  put 'v1.0/patrons/:id', to: 'patrons#new'
  put 'v1.0/patrons/:id/pnr', to: 'patrons#pnr'
  put 'v1.0/patrons/:id/card', to: 'patrons#card'
  get 'v1.0/nono', to: 'nonos#show'
  get 'v1.0/LibraryCardNumbers/:pnr', to: 'library_card_number#getNumber'
end
