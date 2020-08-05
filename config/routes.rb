Rails.application.routes.draw do
  root 'static_pages#home'
  get  '/signup',   to: 'users#new'
  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  get '/edit-basic-info/:id', to: 'users#edit_basic_info', as: :basic_info
  get 'users/attended', to: 'users#attended', as: :attended_path
  patch 'update-basic-info',  to: 'users#update_basic_info'
  #　勤怠変更関連ルーティング
  get 'users/:id/attendances/:date/edit', to: 'attendances#edit', as: :edit_attendances
  patch 'users/:id/attendances/:date/update', to: 'attendances#update', as: :update_attendances
  get 'users/:id/attendances/:date/notice_change_apply', to: 'attendances#notice_change_apply', as: :notice_change_apply
  patch 'confirmation_change_apply', to: 'attendances#confirmation_change_apply', as: :confirmation_change_apply
  #　１ヶ月申請関連ルーティング
  patch 'users/:id/attendances/:date/update_month_apply', to: 'attendances#update_month_apply', as: :update_month_apply
  get 'users/:id/attendances/:date/notice_month_apply', to: 'attendances#notice_month_apply', as: :notice_month_apply
  patch 'confirmation_month_apply', to: 'attendances#confirmation_month_apply', as: :confirmation_month_apply
  #  残業申請関連ルーティング
  get 'users/:id/attendances/:date/overtime_apply', to: 'attendances#overtime_apply', as: :overtime_apply
  patch 'user/:id/attendances/:date/update_overtime_apply', to: 'attendances#update_overtime_apply', as: :update_overtime_apply
  get 'user/:id/attendances/:date/notice_overtime_apply', to: 'attendances#notice_overtime_apply', as: :notice_overtime_apply
  patch 'confirmation_overtime_apply', to: 'attendances#confirmation_overtime_apply', as: :confirmation_overtime_apply
  #　勤怠修正ログ
  get 'user/:id/attendances/:date/approved_attendance', to: 'attendances#approved_attendance', as: :approved_attendance


  resources :users do
    resources :attendances, only: :create
  end
end