Rails.application.routes.draw do

# namespace :v1, :defaults => {:format => :json} do

  # get "fetch_import_data" => "publications#fetch_import_data"

  # put "publications/publish/:id" => "publications#publish"
  # get "publications/review/:id" => "publications#review"
  # get "publications/bibl_review/:id" => "publications#bibl_review"
  # get "publications/set_biblreview_postponed_until/:id" => "publications#set_biblreview_postponed_until"

  # get "publications/feedback_email/:publication_id" => "publications#feedback_email"

  # resources :publications, param: :id
  # get "notes/" => "notes#index"
  # post "notes/" => "notes#create"
  # get "notes/:id" => "notes#show", :constraints  => { :id => /[0-9]+/ }
  # put "notes/:id" => "notes#update", :constraints  => { :id => /[0-9]+/ }
  # delete "notes/:id" => "notes#destroy", :constraints  => { :id => /[0-9]+/ }

  put 'v1.0/patrons/:id', to: 'patrons#new'
  put 'v1.0/patrons/:id/pnr', to: 'patrons#update_pnr'
  put 'v1.0/patrons/:id/validity', to: 'patrons#validity'
  put 'v1.0/patrons/:id/card', to: 'patrons#card'
  get 'v1.0/nono', to: 'nonos#show'
end

#router.attach("/"+VERSION, RootServerResource.class);
#router.attach("/"+VERSION+"/patrons/", PatronsServerResource.class);
#router.attach("/"+VERSION+"/patrons/{identifier}", PatronServerResource.class);
#router.attach("/"+VERSION+"/patrons/{identifier}/pnr", PnrServerResource.class);
#router.attach("/"+VERSION+"/patrons/{identifier}/validity", CardServerResource.class);
#router.attach("/"+VERSION+"/patrons/{identifier}/card", CardServerResource.class);
#router.attach("/"+VERSION+"/nono", NoServerResource.class);
